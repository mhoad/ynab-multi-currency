class YnabAdapter
  def initialize(current_user)
    @api_client = YnabApi::Client.new(current_user.ynab_access_token)
  end

  def budgets
    api_client.budgets.get_budgets.data.budgets.map { |budget| Budget.new(budget) }
  end

  def accounts(budget_id)
    api_client.accounts.get_accounts(budget_id).data.accounts.map { |account| Account.new(account) }
  end

  def transactions(since: nil, budget_id:, account_id:)
    api_client
      .transactions
      .get_transactions_by_account(
        budget_id,
        account_id,
        since_date: since&.to_date&.iso8601
      )
      .data
      .transactions
      .map { |transaction| Transaction.new(transaction) }
  end

  def account(budget_id:, account_id:)
    Account.new(api_client.accounts.get_account_by_id(budget_id, account_id).data.account)
  end

  def upload_transaction(args:, budget_id:)
    api_client.transactions.create_transaction(budget_id, { transaction: prepare_transaction_args(args) }).data.transaction
  end

  def update_transaction(args:, transaction_id:, budget_id:)
    api_client.transactions.update_transaction(budget_id, transaction_id, { transaction: prepare_transaction_args(args) }).data.transaction
  end

  private

  attr_reader :api_client

  def prepare_transaction_args(args)
    if args[:date]
      args[:date] = args[:date].to_date.iso8601
    end

    if args[:memo]
      args[:memo] = args[:memo]&.slice(0...50)
    end

    if args[:payee_name]
      args[:payee_name] = args[:payee_name]&.slice(0...50)
    end

    args
  end
end
