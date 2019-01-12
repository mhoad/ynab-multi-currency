class BudgetsAndAccountsFetcher
  def initialize(user)
    @ynab_adapter = YnabAdapter.new(user)
  end

  def self.call(user)
    new(user).call
  end

  def call
    ynab_adapter.budgets.map do |budget|
      budget.accounts = ynab_adapter.accounts(budget.id)
      budget
    end
  end

  private

  attr_reader :ynab_adapter
end
