class CreateConversions < ActiveRecord::Migration[5.2]
  def change
    create_table :conversions do |t|
      t.string :ynab_budget_id
      t.string :ynab_account_id
      t.string :cached_ynab_account_name
      t.string :cached_ynab_budget_name
      t.string :from_currency
      t.string :to_currency
      t.datetime :synced_at
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
