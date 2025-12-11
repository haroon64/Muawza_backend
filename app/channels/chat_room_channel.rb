class ChatRoomChannel < ApplicationCable::Channel
  @@online_users = Hash.new { |hash, key| hash[key] = [] }

  def subscribed
    @conversation_id = params[:conversation_id]
    @conversation = Conversation.find_by(id: @conversation_id)

    if can_access_conversation?
      stream_from conversation_channel

      @@online_users[@conversation_id] << current_user&.id unless @@online_users[@conversation_id].include?(current_user.id)

      logger.info "User #{current_user.id} subscribed for conversation #{@conversation_id}"

    else
      reject
    end
  end

  def unsubscribed
    if @conversation_id
      @@online_users[@conversation_id].delete(current_user.id)
    end

    stop_all_streams
  end


  def both_online?
    participant_ids = [
      @conversation.customer_profile&.user_id,
      @conversation.vendor_profile&.user_id
    ].compact

    (participant_ids - @@online_users[@conversation_id]).empty?
  end


  def receive(data)
    case data["action"]
    when "message"
      handle_new_message(data)
    when "typing"
      handle_typing(data)
    when "stop_typing"
      handle_stop_typing(data)
    when "mark_read"
      handle_mark_read(data)
    else
      logger.warn "Unknown action: #{data['action']}"
    end
  end


  def send_message(data)
    handle_new_message(data)
  end

  def typing(data)
    handle_typing(data)
  end

  def stop_typing(data)
    handle_stop_typing(data)
  end

  def mark_read(data)
    handle_mark_read(data)
  end

  private

  # ===========================================
  # CHANNEL NAME
  # ===========================================
  def conversation_channel
    "conversation_#{@conversation_id}"
  end

  # ===========================================
  # AUTHORIZATION CHECK
  # ===========================================
  def can_access_conversation?
    return false unless @conversation && current_user

    customer_user_id = @conversation.customer_profile&.user_id
    vendor_user_id = @conversation.vendor_profile&.user_id

    current_user.id == customer_user_id || current_user.id == vendor_user_id
  end

  # ===========================================
  # MESSAGE HANDLERS
  # ===========================================
  def handle_new_message(data)
    
    return unless @conversation

    content = data["content"]

    message_type = data["message_type"] || "text"

    message = @conversation.messages.new(
      sender_id: current_user.id,
      body: content
    )

    if message.save
      @conversation.touch

      broadcast_message(message)

      broadcast_notification(message)
      logger.info "Message ##{message.id} sent in conversation ##{@conversation_id}"
    else
      transmit({
        type: "error",
        action: "message_failed",
        errors: message.errors.full_messages,
        temp_id: data["temp_id"]
      })
    end
  end


  def handle_typing(data)
    ActionCable.server.broadcast(
      conversation_channel,
      {
        type: "typing",
        user_id: current_user.id,
        user_name: current_user_name,
        conversation_id: @conversation_id
      }
    )
  end

  def handle_stop_typing(data)
    ActionCable.server.broadcast(
      conversation_channel,
      {
        type: "stop_typing",
        user_id: current_user.id,
        conversation_id: @conversation_id
      }
    )
  end

  def broadcast_message(message)
    ActionCable.server.broadcast(
      conversation_channel,
      {
        type: "new_message",
        message: serialize_message(message),
        conversation_id: @conversation_id
      }
    )
  end

  def broadcast_notification(message)
    receiver_id = get_receiver_id
    receiver_channel = "notifications_#{receiver_id}"

    ActionCable.server.broadcast(
      receiver_channel,
      {
        type: "new_message_notification",
        conversation_id: @conversation_id,
        message: serialize_message(message),
        sender: {
          id: current_user.id,
          name: current_user_name,
          avatar: current_user_avatar
        }
      }
    )
  end

  def get_receiver_id
    customer_user_id = @conversation.customer_profile&.user_id
    vendor_user_id = @conversation.vendor_profile&.user_id

    current_user.id == customer_user_id ? vendor_user_id : customer_user_id
  end

  def current_user_name
    profile = get_current_user_profile
    profile&.full_name || "User #{current_user.id}"
  end

  def current_user_avatar
    profile = get_current_user_profile
    return nil unless profile&.profile_image&.attached?

    Rails.application.routes.url_helpers.rails_blob_path(
      profile.profile_image,
      only_path: true
    )
  end

  def get_current_user_profile
    CustomerProfile.find_by(user_id: current_user.id) ||
      VendorProfile.find_by(user_id: current_user.id)
  end

  def serialize_message(message)
    {
      id: message.id,
      conversation_id: message.conversation_id,
      sender_id: message.sender_id,
      body: message.body,
     
      timestamp: message.created_at.iso8601
    }
  end

  # def attachments_data(message)
  #   return [] unless message.attachments.attached?

  #   message.attachments.map do |file|
  #     {
  #       filename: file.filename.to_s,
  #       content_type: file.content_type,
  #       url: url_for(file),
  #       size: file.byte_size
  #     }
  #   end
  # end
end
