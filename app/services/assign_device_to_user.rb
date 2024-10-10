# frozen_string_literal: true

class AssignDeviceToUser
  def initialize(requesting_user:, serial_number:, new_device_owner_id:)
    @requesting_user = requesting_user
    @serial_number = serial_number
    @new_device_owner_id = new_device_owner_id.to_i
  end

  def call
    authorize_user!

    if user_previously_returned_device?
      raise AssigningError::AlreadyUsedOnUser, "User has previously returned a device with serial number #{@serial_number}"
    end

    device = Device.find_by(serial_number: @serial_number)

    if device
      handle_existing_device(device)
    else
      handle_new_device
    end
  end

  private

  # Authorizes that the requesting user is assigning the device to themselves
  def authorize_user!
    raise RegistrationError::Unauthorized, "User #{@requesting_user.id} is not authorized to assign device to user #{@new_device_owner_id}" unless authorized_user?
  end

  # Checks if the user has previously returned any device with the given serial number
  def user_previously_returned_device?
    ReturnedDevice.joins(:device)
                  .where(user_id: @requesting_user.id, devices: { serial_number: @serial_number })
                  .exists?
  end

  # Handles the scenario where the device already exists
  def handle_existing_device(device)
    raise AssigningError::AlreadyUsedOnOtherUser, "Device #{@serial_number} is already assigned to another user" if device_assigned_to_other_user?(device)

    assign_device_to_user(device)
  end

  # Handles the scenario where the device does not exist
  def handle_new_device
    Device.create!(serial_number: @serial_number, user: @requesting_user)
  end

  # Checks if the device is assigned to another user
  def device_assigned_to_other_user?(device)
    device.user.present? && device.user_id != @requesting_user.id
  end

  # Assigns the device to the requesting user
  def assign_device_to_user(device)
    device.update!(user: @requesting_user)
  end

  # Checks if the requesting user is authorized to assign the device
  def authorized_user?
    @requesting_user.id == @new_device_owner_id
  end
end