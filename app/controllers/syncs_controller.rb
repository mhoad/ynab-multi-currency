class SyncsController < ApplicationController
  include ActionView::Helpers::TextHelper

  def new
    @conversion = Conversion.find(params[:conversion_id])
    @sync = @conversion.create_draft_sync(since)
  end

  def create
    sync = Sync.find(params[:sync_id])
    sync.confirm!

    flash[:notice] = "Succesfully synced #{pluralize(sync.transactions.count, "transaction")} "

    sync.update(transactions: nil)

    redirect_to(conversions_path)
  end

  private

  def since
    if params[:since]
      Date.parse(params[:since])
    else
      @conversion.last_synced_at || raise("A date must me provided for the first sync")
    end
  end
end
