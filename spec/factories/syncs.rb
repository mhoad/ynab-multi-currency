FactoryBot.define do
  factory :sync do
    transactions do
      [
        Ynaby::Transaction.new(
          date: Date.yesterday,
          amount: 300.0,
          memo: "My memo",
          payee_name: "George Constanza",
          account: build(:ynab_account)
        )
      ]
    end

    factory :conversion_sync do
      association :add_on, factory: :conversion
    end
  end
end
