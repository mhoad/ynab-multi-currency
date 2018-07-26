class SyncsController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_action :authenticate_user!, :authorize_ynab!

  def new
    @sync = conversion.create_draft_sync(since)

    if @sync.transactions.blank?
      @sync.confirm!

      flash[:alert] = "No transactions found to convert"

      redirect_to conversions_path
    end
  end

  def create
    sync = conversion.syncs.find(params[:sync_id])
    count = sync.confirm!

    flash[:notice] = "Succesfully synced #{pluralize(count, "transaction")}"

    redirect_to(conversions_path)
  end

  private

  def conversion
    current_user.conversions.find(params[:conversion_id])
  end

  def since
    if params[:since]
      Date.parse(params[:since])
    else
      conversion.last_synced_at || raise("A date must me provided for the first sync")
    end
  end
end
