FactoryBot.define do
  factory :ynab_budget, class: Ynaby::Budget do
    id { "123" }
    name { "My budget" }
    last_modified_on { 1.day.ago }
    date_format { {} }
    currency_format { { iso_code: "EUR" } }
    user { Ynaby::User.new("abc") }
  end

  initialize_with { new(attributes) }
end
