FactoryBot.define do
  factory :add_on do
    ynab_budget_id { "ABC" }
    ynab_account_id { "DEF" }
    cached_ynab_account_name { "Checking Account" }
    cached_ynab_budget_name { "My budget" }
    start_date { Date.yesterday }
    memo_position { "left" }
    user

    factory :conversion do
      from_currency { "USD" }
      to_currency { "EUR" }
      type { "Conversion" }
    end
  end
end
