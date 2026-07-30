require 'rails_helper'

RSpec.describe AnthropicConversation, type: :model do
  describe 'validations' do
    it 'is valid with required attributes' do
      expect(build(:anthropic_conversation)).to be_valid
    end

    it 'requires messages_id' do
      conversation = build(:anthropic_conversation, messages_id: nil)

      expect(conversation).not_to be_valid
      expect(conversation.errors[:messages_id]).to include("can't be blank")
    end

    it 'requires messages' do
      conversation = build(:anthropic_conversation, messages: nil)

      expect(conversation).not_to be_valid
      expect(conversation.errors[:messages]).to include("can't be blank")
    end
  end
end
