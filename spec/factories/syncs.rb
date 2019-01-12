FactoryBot.define do
  factory :sync do
    transactions do
      [
        Transaction.new(
          YNAB::TransactionDetail.new(
            date: Date.yesterday,
            amount: 300.0,
            memo: "My memo",
            payee_name: "George Constanza"
          )
        )
      ]
    end

    factory :conversion_sync do
      association :add_on, factory: :conversion
    end
  end
end
