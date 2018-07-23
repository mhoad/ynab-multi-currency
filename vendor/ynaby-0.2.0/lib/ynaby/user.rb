module Ynaby
  class User < Base
    attr_reader :api_token

    def initialize(api_token)
      @api_token = api_token
    end

    def budgets
      response = ynab_client.budgets.get_budgets
      response.data.budgets.map do |budget|
        Budget.parse(budget, self)
      end
    end

    def budget(id)
      budgets.find { |budget| budget.id == id }
    end
  end
end
