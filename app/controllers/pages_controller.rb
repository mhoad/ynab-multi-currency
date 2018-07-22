class PagesController < ApplicationController
  def home
    redirect_to conversions_path
  end
end
