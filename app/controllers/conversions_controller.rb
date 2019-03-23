class ConversionsController < AddOnsController
  def index
    redirect_to add_ons_path
  end

  def new
    @add_on = Conversion.new
    @accounts_by_budget = accounts_by_budget
  end

  def edit
    @add_on = current_user.conversions.active.find(params[:id])
    @accounts_by_budget = accounts_by_budget
  end

  private

  def add_on_params
    params
      .require(:conversion)
      .permit(
        :ynab_account_id,
        :ynab_budget_id,
        :cached_ynab_account_name,
        :cached_ynab_budget_name,
        :from_currency,
        :to_currency,
        :sync_automatically,
        :start_date,
        :memo_position,
        :offset,
        :custom_fx_rate
      ).merge(
        type: "Conversion"
      )
  end

  def service
    Conversions
  end
end
