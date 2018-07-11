module Ynaby
  class Budget
    include Ynaby::ApiHelper

    attr_reader :id, :name, :currency_format

    def initialize(id:, name:, last_modified_on:, date_format:, currency_format:)
      @id = id
      @name = name
      @last_modified_on = last_modified_on
      @date_format = date_format
      @currency_format = currency_format || {}
    end

    def self.all
      response = ynab_client.budgets.get_budgets
      response.data.budgets.map do |budget|
        parse(budget)
      end
    end

    def self.find(id)
      all.find { |budget| budget.id == id }
    end

    def accounts
      response = self.class.ynab_client.accounts.get_accounts(@id)
      response.data.accounts.map do |account|
        Account.parse(object: account, budget_id: @id)
      end
    end

    def currency_code
      currency_format[:iso_code]
    end

    private

    def self.parse(object)
      new(
        id: object.id,
        name: object.name,
        last_modified_on: object.last_modified_on,
        date_format: object.date_format.to_hash,
        currency_format: object.currency_format.to_hash
      )
    end
  end
end
