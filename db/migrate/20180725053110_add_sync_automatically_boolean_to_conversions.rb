class AddSyncAutomaticallyBooleanToConversions < ActiveRecord::Migration[5.2]
  def change
    add_column :conversions, :sync_automatically, :boolean, default: true
  end
end
