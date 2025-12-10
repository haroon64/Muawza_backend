class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  # has_many_attached :attachments
  validates :body, presence: true
end
