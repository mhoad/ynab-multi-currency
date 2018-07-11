require "ynab"

module Ynaby
  module ApiHelper
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def ynab_client
        @ynab_client ||= YnabApi::Client.new(Ynaby.api_token)
      end
    end
  end
end
