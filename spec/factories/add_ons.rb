FactoryBot.define do
  factory :add_on do
    ynab_budget_id { "ABC" }
    ynab_account_id { "DEF" }
    cached_ynab_account_name { "Checking Account" }
    cached_ynab_budget_name { "My budget" }
    start_date { Date.yesterday }
    memo_position { "left" }
    sync_automatically { true }
    user

    factory :conversion, class: "Conversion" do
      from_currency { "USD" }
      to_currency { "EUR" }
    end

    trait :deleted do
      deleted_at { 1.day.ago }
    end
  end
end
