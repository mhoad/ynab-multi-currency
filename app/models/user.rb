class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :conversions

  def requires_ynab_authorization?
    ynab_access_token.blank? || ynab_expires_at.past?
  end
end
