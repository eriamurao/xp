FactoryBot.define do
  factory :event do
    name { Faker::Lorem.word }
    start_time { 6.months.ago }
    end_time { 6.months.from_now }
    max_capacity { Faker::Number.between(from: 1, to: 100) }
  end
end
