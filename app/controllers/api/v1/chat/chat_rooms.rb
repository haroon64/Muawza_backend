class Api::V1::Chat::ChatRoomsController < ApplicationController
    before_action :set_chat_room, only: [:show, :update, :destroy]

    # GET /api/v1/chat/chat_rooms
    def index
      @chat_rooms = ChatRoom.all
      render json: @chat_rooms
    end

    # GET /api/v1/chat/chat_rooms/:id
    def show
      render json: @chat_room
    end

    # POST /api/v1/chat/chat_rooms
    def create
      @chat_room = ChatRoom.new(chat_room_params)

      if @chat_room.save
        render json: @chat_room, status: :created
      else
        render json: @chat_room.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/chat/chat_rooms/:id
    def update
      if @chat_room.update(chat_room_params)
        render json: @chat_room
      else
        render json: @chat_room.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/chat/chat_rooms/:id
    def destroy
      @chat_room.destroy
      head :no_content
    end

    private

    def set_chat_room
      @chat_room = ChatRoom.find(params[:id])
    end

    def chat_room_params
      params.require(:chat_room).permit(:user_id1, :user_id2)
    end
  end

