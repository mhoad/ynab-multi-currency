class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :conversions

  def requires_ynab_authorization?
    ynab_access_token.blank?
  end

  def requires_ynab_refresh?
    ynab_expires_at&.past?
  end

  def ynab_user
    Ynaby::User.new(ynab_access_token)
  end
end
