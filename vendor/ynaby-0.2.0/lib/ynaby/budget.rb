module Ynaby
  class Budget < Base
    attr_reader :id, :name, :currency_format, :user

    def initialize(id:, name:, last_modified_on:, date_format:, currency_format:, user:)
      @id = id
      @name = name
      @last_modified_on = last_modified_on
      @date_format = date_format
      @currency_format = currency_format || {}
      @user = user
    end

    def accounts
      response = ynab_client.accounts.get_accounts(@id)
      response.data.accounts.map do |account|
        Account.parse(object: account, budget: self)
      end
    end

    def account(account_id)
      response = ynab_client.accounts.get_account_by_id(id, account_id)
      Account.parse(object: response.data.account, budget: self)
    end

    def currency_code
      currency_format[:iso_code]
    end

    def self.parse(object, user)
      new(
        id: object.id,
        name: object.name,
        last_modified_on: object.last_modified_on,
        date_format: object.date_format.to_hash,
        currency_format: object.currency_format.to_hash,
        user: user
      )
    end

    def api_token
      user.api_token
    end
  end
end
