# frozen_string_literal: true

class ReturnDeviceFromUser
  def initialize(user:, serial_number:, from_user:)
    @user = user
    @serial_number = serial_number
    @from_user_id = from_user.to_i
  end

  def call
    device = find_device!
    authorize_device_return!(device)

    ActiveRecord::Base.transaction do
      record_returned_device(device)
      unassign_device(device)
    end

    Rails.logger.info("Device #{@serial_number} successfully returned by User #{@user.id}.")
  rescue StandardError => e
    Rails.logger.error("Failed to return Device #{@serial_number} by User #{@user.id}: #{e.message}")
    raise
  end

  private

  # Finds the device by serial number or raises an error if not found.
  def find_device!
    Device.find_by(serial_number: @serial_number) || raise(
      ReturningError::DeviceNotFound,
      "Device with serial number #{@serial_number} not found."
    )
  end

  # Authorizes that the user is allowed to return the device.
  def authorize_device_return!(device)
    raise ReturningError::Unauthorized, "User #{@user.id} is not authorized to return device #{@serial_number}." unless authorized_to_return?(device)
  end

  # Checks if the user is authorized to return the device.
  def authorized_to_return?(device)
    device.user_id == @user.id && @user.id == @from_user_id
  end

  # Records the returned device in the database.
  def record_returned_device(device)
    ReturnedDevice.create!(user: @user, device: device)
  end

  # Unassigns the device from the user.
  def unassign_device(device)
    device.update!(user: nil)
  end
end