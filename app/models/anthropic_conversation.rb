class AnthropicConversation < ApplicationRecord
  validates :messages_id, presence: true
  validates :messages, presence: true
end
