class Device < ApplicationRecord
  belongs_to :user, optional: true
  has_many :returned_devices, dependent: :destroy
  has_many :users_returned, through: :returned_devices, source: :user

  validates :serial_number, presence: true, uniqueness: true
end
