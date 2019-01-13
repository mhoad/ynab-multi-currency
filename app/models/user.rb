class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :conversions, dependent: :destroy
  has_many :add_ons, dependent: :destroy
  has_many :bank_imports, dependent: :destroy

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
