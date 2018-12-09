FactoryBot.define do
  factory :ynab_account, class: Ynaby::Account do
    id { "123" }
    name { "Checking account" }
    type { "checking" }
    on_budget { true }
    closed { false }
    note { nil }
    balance { 0.0 }
    cleared_balance { 0.0 }
    uncleared_balance { 0.0 }
    budget { build(:ynab_budget) }
  end

  initialize_with { new(attributes) }
end
