class BudgetsAndAccountsFetcher
  def initialize(user)
    @ynab_adapter = YnabAdapter.new(user)
  end

  def self.call(user)
    new(user).call
  end

  def call
    ynab_adapter.budgets.map do |raw_budget|
      Budget.new(raw_budget, accounts: ynab_adapter.accounts(raw_budget.id))
    end
  end

  private

  attr_reader :ynab_adapter
end
