class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :conversions

  def requires_ynab_authorization?
    ynab_access_token.blank? || invalid_token?
  end

  def ynab_user
    Ynaby::User.new(ynab_access_token)
  end

  def refresh_ynab_token_if_needed!
    if requires_ynab_refresh?
      !!Oauth.new(self).refresh!
    else
      true
    end
  end

  private

  def requires_ynab_refresh?
    ynab_expires_at&.past?
  end

  def invalid_token?
    begin
      !ynab_user.budgets
    rescue YnabApi::ApiError => e
      e.message == "Unauthorized" || raise
    end
  end
end
