FactoryBot.define do
  factory :device do
    sequence(:serial_number) { |n| "SN#{100000 + n}" }
    association :user
  end
end