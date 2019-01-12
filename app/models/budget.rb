class Budget < SimpleDelegator
  attr_accessor :accounts

  def initialize(budget, accounts: [])
    @accounts = accounts
    super(budget)
  end

  def currency_code
    __getobj__.currency_format.iso_code
  end
end
