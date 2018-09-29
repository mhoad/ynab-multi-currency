class SyncsController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_action :authenticate_user!
  around_action :authorize_ynab!

  def new
    @sync = conversion.create_draft_sync

    if @sync.transactions.blank?
      @sync.confirm!

      flash[:alert] = "No transactions found to convert"

      redirect_to conversions_path
    end
  end

  def create
    sync = conversion.syncs.find(params[:sync_id])

    if sync.transactions.blank?
      flash[:alert] = "Oops! You took too long to confirm your transactions so we had to cancel the operation. Here's a fresh batch for you to review again."
      redirect_to new_conversion_sync_path(conversion)
    else
      count = sync.confirm!
      flash[:notice] = "Succesfully synced #{pluralize(count, "transaction")}"
      redirect_to conversions_path
    end
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
