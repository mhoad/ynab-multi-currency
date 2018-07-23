module Ynaby
  class Account < Base
    attr_reader :id, :name, :budget

    def initialize(id:,
                   name:,
                   type:,
                   on_budget:,
                   closed:,
                   note:,
                   balance:,
                   cleared_balance:,
                   uncleared_balance:,
                   budget:)

      @id = id
      @name = name
      @type = type
      @on_budget = on_budget
      @closed = closed
      @note = note
      @balance = balance
      @cleared_balance = cleared_balance
      @uncleared_balance = uncleared_balance
      @budget = budget
    end

    def transactions(since: nil)
      response = ynab_client
        .transactions
        .get_transactions_by_account(
          budget.id,
          @id,
          since_date: since&.to_date&.iso8601
        )

      response.data.transactions.map do |transaction|
        Transaction.parse(object: transaction, account: self)
      end
    end

    def formatted_balance
      (@balance.to_i / 1000).to_s
    end

    def bulk_upload_transactions(transactions)
      if transactions.to_a.empty?
        return {
          new: 0,
          updated: 0
        }
      end

      body = {
        transactions: transactions.map(&:upload_hash)
      }


      if multiple_budgets?(transactions)
        raise "Can only upload transactions into one budget at a time"
      end

      response = ynab_client.transactions.bulk_create_transactions(budget.id, body)
      duplicate_transactions = response.data.bulk.duplicate_import_ids

      if duplicate_transactions.any?
        update_duplicate_transactions(
          new_transactions: transactions,
          duplicate_transactions_ids: response.data.bulk.duplicate_import_ids
        )
      end

      {
        new: response.data.bulk.transaction_ids.count,
        updated: duplicate_transactions.count
      }
    end

    def transaction(transaction_id)
      response = ynab_client.transactions.get_transactions_by_id(budget.id, transaction_id)

      Transaction.parse(object: response.data.transaction, account: self)
    end

    def self.parse(object:, budget:)
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
        budget: budget
      )
    end

    def api_token
      budget.api_token
    end

    private

    def multiple_budgets?(transactions)
      budget_id = transactions.budget_id
      transactions.any? { |transaction| transaction.budget_id != budget_id }
    end

    def update_duplicate_transactions(new_transactions:, duplicate_transactions_ids:)
      old_transactions = find_from_import_ids(duplicate_transactions_ids)

      old_transactions.each do |old_transaction|
        new_transaction = new_transactions.find do |transaction|
          transaction.import_id == old_transaction.import_id
        end

        new_transaction.id = old_transaction.id
        new_transaction.update
      end
    end

    def find_from_import_ids(import_ids)
      earliest_import_date = import_ids.sort.first.split(":")[1]

      ynab_transactions = ynab_client.transactions.get_transactions(
        budget.id,
        since_date: earliest_import_date
      ).data.transactions

      parsed_transactions = ynab_transactions.map do |transaction_object|
        Transaction.parse(object: transaction_object, account: self)
      end

      parsed_transactions.select do |transaction|
        import_ids.include?(transaction.import_id)
      end
    end
  end
end
