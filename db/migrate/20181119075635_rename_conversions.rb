class RenameConversions < ActiveRecord::Migration[5.2]
  def change
    rename_table :conversions, :add_ons
    rename_column :syncs, :conversion_id, :add_on_id
    add_column :add_ons, :type, :string
  end
end
