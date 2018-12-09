module Conversions
  class Finalizer
    def self.call(sync)
      YnabAdapter.new(sync.add_on.user).batch_update(sync.transactions)
      count = sync.transactions.count
      sync.update!(confirmed: true, transactions: nil)
      count
    end
  end
end
