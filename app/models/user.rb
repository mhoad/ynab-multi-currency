class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :conversions, dependent: :destroy

  def requires_ynab_authorization?
    ynab_access_token.blank? || !refresh_ynab_token_if_needed!
  end

  def ynab_user
    Ynaby::User.new(ynab_access_token)
  end

  def refresh_ynab_token_if_needed!
    if ynab_expires_at&.past?
      !!Oauth.new(self).refresh!
    else
      true
    end
  end

  def subscribe_to_newsletter!
    if Rails.env.production?
      mailchimp_api_key = Rails.application.credentials.mailchimp_api_key
      mailchimp_list_id = Rails.application.credentials.mailchimp_list_id

      gibbon = Gibbon::Request.new(api_key: mailchimp_api_key)

      gibbon.lists(mailchimp_list_id).members.create(
        body: {
          email_address: email,
          status: "subscribed"
        }
      )
    end
  end
end
