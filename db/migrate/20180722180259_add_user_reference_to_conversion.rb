class AddUserReferenceToConversion < ActiveRecord::Migration[5.2]
  def change
    add_reference :conversions, :user
  end
end
