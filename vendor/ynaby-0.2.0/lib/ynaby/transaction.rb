module Ynaby
  class Transaction < Base
    attr_reader :account, :date, :payee_name, :import_id
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
                   account:)

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
      @account = account
    end

    def upload
      body = {
        transaction: upload_hash
      }

      response = ynab_client.transactions.create_transaction(budget_id, body)

      self.class.parse(object: response.data.transaction, account: account)
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

    def update
      body = {
        transaction: upload_hash
      }

      response = ynab_client.transactions.update_transaction(budget_id, id, body)

      self.class.parse(object: response.data.transaction, account: account)
    end

    def self.parse(object:, account:)
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
        account: account
      )
    end

    def budget_id
      account.budget.id
    end

    private

    def api_token
      account.api_token
    end
  end
end
