class AddConstraintsToDevices < ActiveRecord::Migration[7.1]
  def change
    change_column_null :devices, :serial_number, false
    add_index :devices, :serial_number, unique: true
  end
end
