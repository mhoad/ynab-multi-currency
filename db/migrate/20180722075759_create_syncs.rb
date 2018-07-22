class CreateSyncs < ActiveRecord::Migration[5.2]
  def change
    create_table :syncs do |t|
      t.references :conversion
      t.text :transactions
      t.boolean :confirmed, default: false

      t.timestamps
    end
  end
end
