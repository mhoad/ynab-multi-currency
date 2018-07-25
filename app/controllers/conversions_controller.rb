class ConversionsController < ApplicationController
  before_action :authenticate_user!, :authorize_ynab!

  def index
    @conversions = current_user.conversions
  end

  def new
    @conversion = Conversion.new
    @ynab_budgets = current_user.ynab_user.budgets
    @currency_options = ExchangeRate.currencies.map do |currency|
      [
        "#{currency.iso_code} - #{currency.name}",
        currency.iso_code
      ]
    end
  end

  def create
    conversion = current_user.conversions.create!(conversion_params)
    redirect_to(new_conversion_sync_path(conversion, since: params[:since]))
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
        :to_currency,
        :sync_automatically
      )
  end
end
