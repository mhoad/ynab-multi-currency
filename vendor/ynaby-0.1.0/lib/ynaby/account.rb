module Ynaby
  class Account
    include Ynaby::ApiHelper

    attr_reader :id, :name, :budget_id

    def initialize(id:,
                   name:,
                   type:,
                   on_budget:,
                   closed:,
                   note:,
                   balance:,
                   cleared_balance:,
                   uncleared_balance:,
                   budget_id:)

      @id = id
      @name = name
      @type = type
      @on_budget = on_budget
      @closed = closed
      @note = note
      @balance = balance
      @cleared_balance = cleared_balance
      @uncleared_balance = uncleared_balance
      @budget_id = budget_id
    end

    def transactions(since: nil)
      response = self.class.ynab_client
        .transactions
        .get_transactions_by_account(
          @budget_id,
          @id,
          since_date: since&.to_date&.iso8601
        )

      response.data.transactions.map do |transaction|
        Transaction.parse(object: transaction, budget_id: @budget_id)
      end
    end

    def self.find(budget_id:, account_id:)
      response = ynab_client.accounts.get_account_by_id(budget_id, account_id)
      Account.parse(object: response.data.account, budget_id: budget_id)
    end

    def formatted_balance
      (@balance.to_i / 1000).to_s
    end

    private

    def self.parse(object:, budget_id:)
      new(
        id: object.id,
        name: object.name,
        type: object.type,
        on_budget: object.on_budget,
        closed: object.closed,
        note: object.note,
        balance: object.balance,
        cleared_balance: object.cleared_balance,
        uncleared_balance: object.uncleared_balance,
        budget_id: budget_id
      )
    end
  end
end
