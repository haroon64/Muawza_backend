class Api::V1::Conversations::MessagesController < ApplicationController
    before_action :set_message, only: [ :show, :update, :destroy ]



    def show
      render json: @message
    end

    # POST /api/v1/chat/messages
    def create
      @message = Message.new(message_params)
      if @message.save
        # optional: broadcast to chat_room_channel if using websockets
        ActionCable.server.broadcast(
          "chat_room_#{@message.chat_room_id}",
          {
            id: @message.id,
            body: @message.body,
            chat_room_id: @message.chat_room_id,
            sender_id: @message.sender_id,
            created_at: @message.created_at
          }
        )
        render json: @message, status: :created
      else
        render json: @message.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/chat/messages/:id
    def update
      if @message.update(message_params)
        render json: @message
      else
        render json: @message.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/chat/messages/:id
    def destroy
      @message.destroy
      head :no_content
    end

    private

    def set_message
      @message = Message.find(params[:id])
    end

    def message_params
      params.require(:message).permit(:body, :chat_room_id, :sender_id)
    end
end
