class ConversionsController < ApplicationController
  before_action :authenticate_user!, :authorize_ynab!

  def index
    @conversions = current_user.conversions.active.order(:created_at)
  end

  def new
    @conversion = Conversion.new
    @ynab_budgets = current_user.ynab_user.budgets
    @currency_options = currency_options
  end

  def create
    @conversion = current_user.conversions.new(conversion_params)

    if @conversion.save
      redirect_to(new_conversion_sync_path(@conversion, since: params[:since]))
    else
      @ynab_budgets = current_user.ynab_user.budgets
      @currency_options = currency_options
      render :edit
    end
  end

  def edit
    @conversion = current_user.conversions.active.find(params[:id])
    @ynab_budgets = current_user.ynab_user.budgets
    @currency_options = currency_options
  end

  def update
    @conversion = current_user.conversions.active.find(params[:id])

    if @conversion.update(conversion_params)
      flash[:notice] = "Your conversion has been updated."
      redirect_to conversions_path
    else
      @ynab_budgets = current_user.ynab_user.budgets
      @currency_options = currency_options
      render :edit
    end
  end

  def destroy
    conversion = current_user.conversions.find(params[:id])
    conversion.update(deleted_at: Time.current)

    flash[:notice] = "Your conversion has been deleted."

    redirect_to conversions_path
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

  def currency_options
    ExchangeRate.currencies.map do |currency|
      [
        "#{currency.iso_code} - #{currency.name}",
        currency.iso_code
      ]
    end
  end
end
