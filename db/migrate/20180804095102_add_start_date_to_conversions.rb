class AddStartDateToConversions < ActiveRecord::Migration[5.2]
  def change
    add_column :conversions, :start_date, :date
  end
end
