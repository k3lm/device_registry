class Device < ApplicationRecord
  belongs_to :user, optional: true
  has_many :returned_devices
  has_many :users_returned, through: :returned_devices, source: :user
end
