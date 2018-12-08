class SyncsController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_action :authenticate_user!
  around_action :authorize_ynab!

  def create
    sync = add_on.create_draft_sync
    redirect_to(url_for([add_on, sync, only_path: true, action: :edit]))
  end

  def edit
    @sync = add_on.syncs.find(params[:id])

    if @sync.confirmed?
      @sync = add_on.create_draft_sync
    end

    if @sync.transactions.blank?
      @sync.confirm!
      redirect_to conversions_path, alert: "No transactions found to convert"
    end
  end

  def update
    sync = add_on.syncs.find(params[:sync_id])

    if sync.transactions.blank?
      sync = add_on.create_draft_sync
      redirect_to url_for([add_on, sync, only_path: true, action: :edit]), alert: "Oops! You took too long to confirm your transactions so we had to cancel the operation. Here's a fresh batch for you to review again."
    else
      count = sync.confirm!
      redirect_to url_for([add_on.class, only_path: true]), notice: "Succesfully synced #{pluralize(count, "transaction")}"
    end
  end

  private

  def add_on
    @add_on ||= current_user.add_ons.find(params[:conversion_id] || params[:bank_import_id])
  end
end
