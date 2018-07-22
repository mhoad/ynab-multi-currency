class SyncsController < ApplicationController
  def new
    @conversion = Conversion.find(params[:conversion_id])
    @sync = @conversion.create_draft_sync(since)
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
