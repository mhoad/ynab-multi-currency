module Ynaby
  class Transaction
    include Ynaby::ApiHelper

    attr_reader :budget_id, :date, :payee_name, :import_id
    attr_accessor :id, :memo, :amount

    def initialize(id: nil,
                   date:,
                   amount:,
                   memo: nil,
                   cleared: nil,
                   approved: nil,
                   flag_color: nil,
                   account_id:,
                   payee_id: nil,
                   category_id: nil,
                   transfer_account_id: nil,
                   import_id: nil,
                   account_name: nil,
                   payee_name:,
                   category_name: nil,
                   budget_id:)

      @id = id
      @date = date
      @amount = amount
      @memo = memo
      @cleared = cleared
      @approved = approved
      @flag_color = flag_color
      @account_id = account_id
      @payee_id = payee_id
      @category_id = category_id
      @transfer_account_id = transfer_account_id
      @import_id = import_id
      @account_name = account_name
      @payee_name = payee_name
      @category_name = category_name
      @budget_id = budget_id
    end

    def upload
      body = {
        transaction: upload_hash
      }

      response = self.class.ynab_client.transactions.create_transaction(@budget_id, body)

      self.class.parse(object: response.data.transaction, budget_id: @budget_id)
    end

    def self.bulk_upload(transactions)
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

      budget_id = transactions.first.budget_id
      response = ynab_client.transactions.bulk_create_transactions(budget_id, body)
      duplicate_transactions = response.data.bulk.duplicate_import_ids

      if duplicate_transactions.any?
        update_duplicate_transactions(
          new_transactions: transactions,
          duplicate_transactions_ids: response.data.bulk.duplicate_import_ids,
          budget_id: budget_id
        )
      end

      {
        new: response.data.bulk.transaction_ids.count,
        updated: duplicate_transactions.count
      }
    end

    def upload_hash
      {
        account_id: @account_id,
        date: @date.to_date.iso8601,
        amount: @amount,
        payee_name: @payee_name,
        import_id: @import_id,
        payee_id: nil,
        memo: @memo&.slice(0...50)
      }
    end

    def self.find(budget_id:, transaction_id:)
      response = ynab_client.transactions.get_transactions_by_id(budget_id, transaction_id)

      parse(object: response.data.transaction, budget_id: budget_id)
    end

    def update
      body = {
        transaction: upload_hash
      }

      response = self.class.ynab_client.transactions.update_transaction(@budget_id, @id, body)

      self.class.parse(object: response.data.transaction, budget_id: @budget_id)
    end

    private

    def self.parse(object:, budget_id:)
      new(
        id: object.id,
        date: object.date,
        amount: object.amount.to_i,
        memo: object.memo,
        cleared: object.cleared,
        approved: object.approved,
        flag_color: object.flag_color,
        account_id: object.account_id,
        payee_id: object.payee_id,
        category_id: object.category_id,
        transfer_account_id: object.transfer_account_id,
        import_id: object.import_id,
        account_name: object.account_name,
        payee_name: object.payee_name,
        category_name: object.category_name,
        budget_id: budget_id
      )
    end

    def self.multiple_budgets?(transactions)
      budget_id = transactions.first.budget_id
      transactions.any? { |transaction| transaction.budget_id != budget_id }
    end

    def self.update_duplicate_transactions(new_transactions:, duplicate_transactions_ids:, budget_id:)
      old_transactions = find_from_import_ids(
        import_ids: duplicate_transactions_ids,
        budget_id: budget_id
      )

      old_transactions.each do |old_transaction|
        new_transaction = new_transactions.find do |transaction|
          transaction.import_id == old_transaction.import_id
        end

        new_transaction.id = old_transaction.id
        new_transaction.update
      end
    end

    def self.find_from_import_ids(import_ids:, budget_id:)
      earliest_import_date = import_ids.sort.first.split(":")[1]

      ynab_transactions = ynab_client.transactions.get_transactions(
        budget_id,
        since_date: earliest_import_date
      ).data.transactions

      parsed_transactions = ynab_transactions.map do |transaction_object|
        parse(object: transaction_object, budget_id: budget_id)
      end

      parsed_transactions.select do |transaction|
        import_ids.include?(transaction.import_id)
      end
    end
  end
end
