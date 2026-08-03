FactoryBot.define do
  factory :link_mapping do
    link_code { Faker::Alphanumeric.alphanumeric(number: 10) }
    redirect_link { Faker::Internet.url }
  end
end
