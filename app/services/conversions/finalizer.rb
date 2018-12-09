module Conversions
  class Finalizer
    def self.call(sync)
      sync.transactions.each(&:update)
      count = sync.transactions.count
      sync.update!(confirmed: true, transactions: nil)
      count
    end
  end
end
