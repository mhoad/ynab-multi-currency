class ConversionsController < ApplicationController
  def index
  end

  def new
    @conversion = Conversion.new
    @ynab_budgets = Ynaby::Budget.all
  end

  def create
  end
end
