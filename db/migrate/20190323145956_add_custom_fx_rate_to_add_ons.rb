class AddCustomFxRateToAddOns < ActiveRecord::Migration[5.2]
  def change
    add_column :add_ons, :custom_fx_rate, :float
  end
end
