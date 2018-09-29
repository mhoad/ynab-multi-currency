class AddMemoPositionToConversions < ActiveRecord::Migration[5.2]
  def change
    add_column :conversions, :memo_position, :integer, default: 0
  end
end
