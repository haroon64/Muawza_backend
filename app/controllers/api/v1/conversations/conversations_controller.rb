class Api::V1::Conversations::ConversationsController < ApplicationController
  before_action :set_conversation, only: [  :update, :destroy ]



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
      user_id = conversation_params[:user_id]
      customer_id = CustomerProfile.find_by(user_id: user_id)&.id
      vendor_id = conversation_params[:vendor_id]

      return render json: { error: "Missing user_id or vendor_id" }, status: :unprocessable_entity if user_id.blank? || vendor_id.blank?

      @conversation = Conversation.find_by(customer_id: customer_id, vendor_id: vendor_id)

      unless @conversation
        @conversation = Conversation.new(customer_id: customer_id, vendor_id: vendor_id)

        unless @conversation.save
          return render json: @conversation.errors, status: :unprocessable_entity
        end
      end

      render json: @conversation, serializer: ConversationSerializers::ConversationShowSerializer, status: :created
    end


    def update
      if @conversation.update(conversation_params)
        render json: @conversation
      else
        render json: @conversation.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @conversation.destroy
      head :no_content
    end

    private

    def set_conversation
      @conversation = ChatRoom.find(params[:id])
    end

    def conversation_params
      params.permit(:user_id, :vendor_id)
    end
end
