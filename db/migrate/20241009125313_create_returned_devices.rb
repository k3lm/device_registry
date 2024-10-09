class CreateReturnedDevices < ActiveRecord::Migration[7.1]
  def change
    create_table :returned_devices do |t|
      t.references :user, null: false, foreign_key: true
      t.references :device, null: false, foreign_key: true

      t.timestamps
    end
  end
end
