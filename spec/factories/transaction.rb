FactoryBot.define do
  factory :transaction do
    id { SecureRandom.uuid }
    date { Date.yesterday }
    amount { -100000 }
    memo { "Food" }
    cleared { "cleared" }
    approved { true }
    account_id { SecureRandom.uuid }
    payee_id { SecureRandom.uuid }
    category_id { SecureRandom.uuid }
    deleted { false }
    account_name { "My Checking Account" }
    payee_name { "Supermarket" }
    category_name { "Groceries" }
    subtransactions { [] }

    trait :with_subtransactions do
      subtransactions do
        [
          YNAB::SubTransaction.new(
            id: SecureRandom.uuid,
            transaction_id: SecureRandom.uuid,
            amount: -30000,
            memo: "",
            category_id: SecureRandom.uuid,
            deleted: false
          )
        ]
      end
    end

    initialize_with { new(YNAB::TransactionDetail.new(attributes)) }
  end
end
