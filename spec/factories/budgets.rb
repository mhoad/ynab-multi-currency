FactoryBot.define do
  factory :budget do
    id { "123" }
    name { "My budget" }
    last_modified_on { 1.day.ago }
    date_format { {} }
    currency_format do
      YNAB::CurrencyFormat.new(
        iso_code: "EUR",
        example_format: "123 456,78",
        decimal_digits: 2,
        decimal_separator: ",",
        symbol_first: false,
        group_separator: " ",
        currency_symbol: "€",
        display_symbol: true
      )
    end
    accounts { [build(:account)] }

    initialize_with do
      accounts = attributes.delete(:accounts)
      Budget.new(YNAB::BudgetSummary.new(attributes), accounts: accounts)
    end
  end
end
