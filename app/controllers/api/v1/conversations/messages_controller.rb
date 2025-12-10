# app/controllers/api/v1/conversations/messages_controller.rb

class Api::V1::Conversations::MessagesController < ApplicationController
  before_action :set_conversation

  def index
    @messages = @conversation.messages
                             .order(created_at: :asc)

    # Optional pagination
    if params[:page].present?
      page = params[:page].to_i
      per_page = (params[:per_page] || 50).to_i
      offset = (page - 1) * per_page

      total_count = @messages.count
      @messages = @messages.limit(per_page).offset(offset)

      render json: {
        messages: serialize_messages(@messages),
        pagination: {
          current_page: page,
          per_page: per_page,
          total_count: total_count,
          total_pages: (total_count.to_f / per_page).ceil
        }
      }
    else
      render json: {
        messages: serialize_messages(@messages)
      }
    end
  end

  # ===========================================
  # POST /api/v1/conversations/:conversation_id/messages
  # ===========================================
  def create
    @message = @conversation.messages.new(message_params)

    if @message.save
      # Update conversation timestamp
      @conversation.touch

      # Broadcast via ActionCable
      broadcast_new_message(@message)

      byebug

      render json: {
        message: serialize_message(@message),
        status: "sent"
      }, status: :created
    else
      render json: {
        errors: @message.errors.full_messages,
        status: "failed"
      }, status: :unprocessable_entity
    end
  end

  # ===========================================
  # POST /api/v1/conversations/:conversation_id/mark_read
  # ===========================================
  # def mark_read
  #   user_id = params[:user_id].to_i

  #   if user_id.blank? || user_id == 0
  #     return render json: { error: "user_id is required" }, status: :unprocessable_entity
  #   end

  #   # Get the receiver_id (the other participant in the conversation)
  #   receiver_id = get_other_participant_id(user_id)

  #   # Mark messages as read where the current user is the receiver
  #   # (i.e., messages sent by the other participant)
  #   updated_count = @conversation.messages
  #                                 .where(sender_id: receiver_id)
  #                                 .where.not(sender_id: user_id)
  #                                 .count

  #   # Broadcast read receipt via ActionCable
  #   if updated_count > 0
  #     broadcast_read_receipt(user_id, updated_count)
  #   end

  #   render json: {
  #     success: true,
  #     messages_marked_read: updated_count,
  #     conversation_id: @conversation.id
  #   }
  # end

  private

  # ===========================================
  # SET CONVERSATION
  # ===========================================
  def set_conversation
    @conversation = Conversation.find_by(id: params[:conversation_id])

    unless @conversation
      render json: { error: "Conversation not found" }, status: :not_found
    end
  end

  # ===========================================
  # STRONG PARAMETERS
  # ===========================================
  def message_params
    params.permit(
      :sender_id,
      :body,


    )
  end

  # ===========================================
  # GET OTHER PARTICIPANT
  # ===========================================
  def get_other_participant_id(user_id)
    customer_user_id = @conversation.customer_profile&.user_id
    vendor_user_id = @conversation.vendor_profile&.user_id

    if user_id.to_i == customer_user_id
      vendor_user_id
    else
      customer_user_id
    end
  end

  # ===========================================
  # ACTIONCABLE BROADCASTS
  # ===========================================
  def broadcast_new_message(message)
    # Get receiver_id for the broadcast
    receiver_id = get_other_participant_id(message.sender_id)

    # Broadcast to conversation channel
    ActionCable.server.broadcast(
      "conversation_#{@conversation.id}",
      {
        type: "new_message",
        message: serialize_message(message),
        conversation_id: @conversation.id
      }
    )

    # Broadcast to receiver's notification channel
    ActionCable.server.broadcast(
      "notifications_#{receiver_id}",
      {
        type: "new_message_notification",
        conversation_id: @conversation.id,
        message: serialize_message(message),
        sender: get_sender_info(message.sender_id)
      }
    )
  end

  def broadcast_read_receipt(reader_id, count)
    # Get other user ID
    other_user_id = get_other_participant_id(reader_id)

    # Broadcast to conversation channel
    ActionCable.server.broadcast(
      "conversation_#{@conversation.id}",
      {
        type: "messages_read",
        reader_id: reader_id,
        conversation_id: @conversation.id,
        count: count,
        read_at: Time.current.iso8601
      }
    )

    # Broadcast to other user's notification channel
    ActionCable.server.broadcast(
      "notifications_#{other_user_id}",
      {
        type: "messages_read",
        reader_id: reader_id,
        conversation_id: @conversation.id,
        count: count,
        read_at: Time.current.iso8601
      }
    )
  end

  def get_sender_info(sender_id)
    # Try to find customer profile first
    profile = CustomerProfile.find_by(user_id: sender_id)
    profile ||= VendorProfile.find_by(user_id: sender_id)

    return { id: sender_id, name: "User #{sender_id}" } unless profile

    {
      id: sender_id,
      name: profile.full_name,
      avatar: profile.profile_image.attached? ? url_for(profile.profile_image) : nil
    }
  end

  # ===========================================
  # SERIALIZATION
  # ===========================================
  def serialize_messages(messages)
    messages.map { |msg| serialize_message(msg) }
  end

  def serialize_message(message)
    # Calculate receiver_id dynamically
    receiver_id = get_other_participant_id(message.sender_id)

    {
      id: message.id,
      conversation_id: message.conversation_id,
      sender_id: message.sender_id,
      receiver_id: receiver_id, # Calculated dynamically
      body: message.body,
      # message_type: message.message_type || "text",
      created_at: message.created_at.iso8601,
      timestamp: message.created_at.iso8601
      # service_inquiry: message.service_inquiry
    }
  end
end
