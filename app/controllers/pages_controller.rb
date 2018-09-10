class PagesController < ApplicationController
  def home
    if user_signed_in?
      redirect_to conversions_path
    end
  end

  def privacy
  end
end
