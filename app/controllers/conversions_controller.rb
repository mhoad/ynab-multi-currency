class ConversionsController < ApplicationController
  def index
  end

  def new
    @conversion = Conversion.new
    @ynab_budgets = Ynaby::Budget.all
  end

  def create
    Conversion.create!(conversion_params)
  end

  private

  def conversion_params
    params
      .require(:conversion)
      .permit(
        :ynab_account_id,
        :ynab_budget_id,
        :cached_ynab_account_name,
        :cached_ynab_budget_name,
        :from_currency,
        :to_currency
      )
  end
end
