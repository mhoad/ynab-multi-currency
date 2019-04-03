module Conversions
  class Finalizer
    def self.call(sync)
      sync.transactions.each do |transaction|
        YnabAdapter.new(sync.add_on.user).update_transaction(
          args: transaction.to_hash.slice(:amount, :memo),
          transaction_id: transaction.id,
          budget_id: sync.add_on.ynab_budget_id
        )
      end

      count = sync.transactions.count
      sync.update!(confirmed: true, transactions: nil, transactions_count: count)
      count
    end
  end
end
