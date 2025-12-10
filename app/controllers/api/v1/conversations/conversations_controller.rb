class Api::V1::Conversations::ConversationsController < ApplicationController
  before_action :set_conversation, only: [ :destroy ]

  def customer_conversations
    user_id = params[:customer_id].to_i
    customer_profile = CustomerProfile.find_by(user_id: user_id)

    unless customer_profile
      return render json: { error: "Customer profile not found" }, status: :not_found
    end

    @conversations = Conversation
      .where(customer_id: customer_profile.id)
      .select("conversations.*, sub_service_id")
      .includes(:vendor_profile, :messages)
      .order(updated_at: :desc)

    conversations_with_unread = @conversations.map do |conv|
      {
        id: conv.id,
        customer_id: conv.customer_id,
        vendor_id: conv.vendor_id,
        vendor_profile: serialize_vendor_profile(conv.vendor_profile),
        sub_service: serialize_sub_service(conv.sub_service_id),
        last_message: serialize_last_message(conv),
        created_at: conv.created_at,
        updated_at: conv.updated_at
      }
    end

    render json: conversations_with_unread
  end

  def vendor_conversations
    vendor_id = params[:vendor_id].to_i
    vendor_profile = VendorProfile.find_by(user_id: vendor_id)

    unless vendor_profile
      return render json: { error: "Vendor profile not found" }, status: :not_found
    end

    @conversations = Conversation
      .where(vendor_id: vendor_profile.id)
      .select("conversations.*, sub_service_id")
      .includes(:customer_profile, :messages)
      .order(updated_at: :desc)


    conversations_with_unread = @conversations.map do |conv|
      {
        id: conv.id,
        customer_id: conv.customer_id,
        vendor_id: conv.vendor_id,
        customer_profile: serialize_customer_profile(conv.customer_profile),
        sub_service: serialize_sub_service(conv.sub_service_id),
        last_message: serialize_last_message(conv),
        created_at: conv.created_at,
        updated_at: conv.updated_at
      }
    end

    render json: conversations_with_unread
  end

    def show
      user_id = params[:id].to_i
      vendor_id = params[:vendor_id].to_i

      customer_profile = CustomerProfile.find_by(user_id: user_id)
      customer_id = customer_profile&.id

      if customer_id.nil? || vendor_id.blank?
        render json: { error: "Missing or invalid user_id or vendor_id" }, status: :unprocessable_entity and return
      end

      @conversation = Conversation.find_by(customer_id: customer_id, vendor_id: vendor_id)

      unless @conversation
        @conversation = Conversation.find_by(customer_id: vendor_id, vendor_id: customer_id)
       puts "show action - Conversation by (vendor_id, customer_id): #{@conversation.inspect}"
      end

      if @conversation
        render json: @conversation, serializer: ConversationSerializers::ConversationShowSerializer
      else
        render json: { error: "Conversation not found for given users" }, status: :not_found
      end
    end

    def create
      user_id        = conversation_params[:customer_id]
      vendor_id      = conversation_params[:vendor_id]
      sub_service_id = conversation_params[:sub_service_id]

      customer_id = CustomerProfile.find_by(user_id: user_id)&.id

      return render json: { error: "SubService not found" }, status: :unprocessable_entity unless SubService.exists?(sub_service_id)
      return render json: { error: "Missing customer_id or vendor_id" }, status: :unprocessable_entity if customer_id.blank? || vendor_id.blank?

      begin
        @conversation = Conversation.find_or_create_by!(
          customer_id: customer_id,
          vendor_id: vendor_id,
          sub_service_id: sub_service_id
        )
      rescue ActiveRecord::RecordNotUnique
        @conversation = Conversation.find_by(
          customer_id: customer_id,
          vendor_id:    vendor_id,
          sub_service_id: sub_service_id
        )
      end

      render json: {
        conversation: ConversationSerializers::ConversationShowSerializer.new(@conversation).as_json,
        status: "success"
      }, status: :ok
    end

    def unread_count
      user_id = params[:user_id].to_i


      unread = Message.where(receiver_id: user_id, is_read: false).count

      render json: { unread_count: unread, user_id: user_id }
    end


    def destroy
      if @conversation.destroy
        render json: { success: true, message: "Conversation deleted successfully." }, status: :ok
      else
        render json: { success: false, errors: @conversation.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_conversation
      @conversation = Conversation.find(params[:id])
    end

    def conversation_params
      params.permit(:user_id, :customer_id, :sub_service_id, :vendor_id)
    end

  def serialize_conversation(conversation)
    {
      id: conversation.id,
      customer_id: conversation.customer_id,
      vendor_id: conversation.vendor_id,
      vendor_profile: serialize_vendor_profile(conversation.vendor_profile),
      customer_profile: serialize_customer_profile(conversation.customer_profile),
      last_message: serialize_last_message(conversation),
      created_at: conversation.created_at,
      updated_at: conversation.updated_at
    }
  end

  def serialize_vendor_profile(profile)
    return nil unless profile
    {
      id: profile.id,
      full_name: profile.full_name,
      profile_image: profile.profile_image.attached? ? url_for(profile.profile_image) : nil
      # location: profile.location,
      # is_verified: profile.is_verified || false,
      # is_online: profile.is_online || false
    }
  end

  def serialize_sub_service(sub_service_id)
    sub_service = SubService.find_by(id: sub_service_id)
    return nil unless sub_service
    {
      id: sub_service.id,
      sub_service_name: sub_service.sub_service_name,
      price: sub_service.price,
      price_bargain: sub_service.price_bargain,
      sub_service_image: sub_service.sub_service_image.attached? ? url_for(sub_service.sub_service_image) : nil
    }
  end
  def serialize_customer_profile(profile)
    return nil unless profile
    {
      id: profile.id,
      full_name: profile.full_name,
      profile_image: profile.profile_image.attached? ? url_for(profile.profile_image) : nil
      # location: profile.location
    }
  end

  def serialize_last_message(conversation)
    last_msg = conversation.messages.order(created_at: :desc).first
    return nil unless last_msg
    {
      body: last_msg.body,
      timestamp: last_msg.created_at,
      # is_read: last_msg.is_read,
      sender_id: last_msg.sender_id
    }
  end
end
