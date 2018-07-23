require "ynab"

module Ynaby
  class Base
    def ynab_client
      YnabApi::Client.new(api_token)
    end
  end
end
