module AddOnsHelper
  def current_user_ynab_budgets
    current_user.ynab_user.budgets
  end
end
