class AddOnsController < ApplicationController
  before_action :authenticate_user!
  around_action :authorize_ynab!, except: [:destroy]

  def index
    @add_ons = current_user.add_ons.active.order(:created_at)
  end

  def create
    @add_on = current_user.add_ons.new(add_on_params)

    if @add_on.save
      sync = @add_on.create_draft_sync
      redirect_to url_for([@add_on, sync, action: :edit, only_path: true, ])
    else
      render :edit
    end
  end

  def update
    @add_on = current_user.conversions.active.find(params[:id])

    if @add_on.update(add_on_params)
      redirect_to add_ons_path, notice: "Your #{add_on.model_name.human.downcase} has been updated."
    else
      render :edit
    end
  end

  def destroy
    conversion = current_user.conversions.find(params[:id])
    conversion.update(deleted_at: Time.current)
    redirect_to conversions_path, notice: "Your #{add_on.model_name.human.downcase} has been deleted."
  end
end
