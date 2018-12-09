class SyncsController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_action :authenticate_user!
  around_action :authorize_ynab!

  def create
    sync = service::Initializer.call(add_on)
    redirect_to(url_for([add_on, sync, only_path: true, action: :edit]))
  end

  def edit
    @sync = add_on.syncs.find(params[:id])

    if @sync.confirmed?
      @sync = service::Initializer.call(add_on)
    end

    if @sync.transactions.blank?
      service::Finalizer.call(@sync)
      redirect_to add_ons_path, alert: "No transactions found to convert"
    end
  end

  def update
    sync = add_on.syncs.find(params[:id])

    if sync.transactions.blank?
      sync = service::Initializer.call(add_on)
      redirect_to url_for([add_on, sync, only_path: true, action: :edit]), alert: "Oops! You took too long to confirm your transactions so we had to cancel the operation. Here's a fresh batch for you to review again."
    else
      count = service::Finalizer.call(sync)
      redirect_to add_ons_path, notice: "Succesfully synced #{pluralize(count, "transaction")}"
    end
  end

  private

  def add_on
    @add_on ||= current_user.add_ons.find(params[:conversion_id] || params[:bank_import_id])
  end

  def service
    if add_on.is_a?(Conversion)
      Conversions
    end
  end
end
