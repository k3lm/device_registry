class User < ApplicationRecord
  has_many :api_keys, as: :bearer
  has_secure_password
  has_many :devices, dependent: :nullify
  has_many :returned_devices, dependent: :destroy
  has_many :devices_returned, through: :returned_devices, source: :device

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
end
