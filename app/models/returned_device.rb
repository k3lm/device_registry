class ReturnedDevice < ApplicationRecord
  belongs_to :user
  belongs_to :device

  validates :user_id, uniqueness: { scope: :device_id }
end
