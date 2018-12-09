class YnabAdapter
  def initialize(current_user)
    @current_user = current_user
  end

  def budgets
    ynab_user.budgets
  end

  def transactions_since(date:, account:)
    account.transactions(since: date)
  end

  def account(budget_id:, account_id:)
    ynab_user.budget(budget_id).account(account_id)
  end

  def batch_update(transactions)
    transactions.each(&:update)
  end

  private

  def ynab_user
    Ynaby::User.new(@current_user.ynab_access_token)
  end
end
