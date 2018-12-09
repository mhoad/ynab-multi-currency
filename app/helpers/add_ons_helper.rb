module AddOnsHelper
  def ynab_budgets
    YnabAdapter.new(current_user).budgets
  end
end
