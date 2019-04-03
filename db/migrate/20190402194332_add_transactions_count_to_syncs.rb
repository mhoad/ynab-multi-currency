class AddTransactionsCountToSyncs < ActiveRecord::Migration[5.2]
  def change
    add_column :syncs, :transactions_count, :integer
  end
end
