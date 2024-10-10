class AddUniqueIndexToReturnedDevices < ActiveRecord::Migration[7.1]
  def change
    add_index :returned_devices, [:user_id, :device_id], unique: true
  end
end
