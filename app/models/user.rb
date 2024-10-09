class User < ApplicationRecord
  has_many :api_keys, as: :bearer
  has_secure_password
  has_many :devices
  has_many :returned_devices
  has_many :devices_returned, through: :returned_devices, source: :device
end
