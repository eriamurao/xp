FactoryBot.define do
  factory :anthropic_conversation do
    sequence(:messages_id) { |n| "msg_#{n}" }
    title { 'Conversation' }
    messages { [ { role: 'user', content: 'Hello' } ] }
  end
end
