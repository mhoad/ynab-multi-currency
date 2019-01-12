FactoryBot.define do
  factory :account do
    id { "123" }
    name { "Checking account" }
    type { "checking" }
    on_budget { true }
    closed { false }
    note { nil }
    balance { 0.0 }
    cleared_balance { 0.0 }
    uncleared_balance { 0.0 }

    initialize_with { new(YNAB::Account.new(attributes)) }
  end
end
