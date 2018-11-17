class AddOffsetToConversions < ActiveRecord::Migration[5.2]
  def change
    add_column :conversions, :offset, :float
  end
end
