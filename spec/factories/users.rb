FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "jerry#{n}@seinfeld.com" }
    password { "jadajadajada" }
    ynab_access_token { SecureRandom.hex(32) }
    ynab_expires_at { 1.day.from_now }
  end
end
