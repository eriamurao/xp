FactoryBot.define do
  factory :anthropic_conversation do
    messages_id { Faker::Alphanumeric.alphanumeric(number: 20) }
    title { Faker::Movies::HarryPotter.spell }
    messages { [ { role: 'user', content: Faker::Movies::HarryPotter.quote } ] }
  end
end
