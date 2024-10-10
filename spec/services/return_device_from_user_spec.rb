# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReturnDeviceFromUser do
  let(:user) { create(:user) }
  let(:serial_number) { '123456' }

  # Helper method to return a device
  def return_device(user: self.user, serial_number: self.serial_number, from_user: user.id)
    described_class.new(
      user: user,
      serial_number: serial_number,
      from_user: from_user
    ).call
  end

  context 'when returning a device successfully' do
    before do
      AssignDeviceToUser.new(
        requesting_user: user,
        serial_number: serial_number,
        new_device_owner_id: user.id
      ).call
    end

    it 'unassigns the device from the user' do
      expect {
        return_device
      }.to change { Device.find_by(serial_number: serial_number).user_id }.from(user.id).to(nil)
    end

    it 'creates a ReturnedDevice record' do
      expect {
        return_device
      }.to change { ReturnedDevice.count }.by(1)

      returned_device = ReturnedDevice.last
      expect(returned_device.user).to eq(user)
      expect(returned_device.device.serial_number).to eq(serial_number)
    end
  end

  context 'when the device does not exist' do
    it 'raises a DeviceNotFound error' do
      expect {
        return_device(serial_number: 'NONEXISTENT')
      }.to raise_error(ReturningError::DeviceNotFound, "Device with serial number NONEXISTENT not found.")
    end
  end

  context 'when the user is not authorized to return the device' do
    let(:other_user) { create(:user) }

    before do
      AssignDeviceToUser.new(
        requesting_user: user,
        serial_number: serial_number,
        new_device_owner_id: user.id
      ).call
    end

    it 'raises an Unauthorized error when another user attempts to return the device' do
      expect {
        return_device(user: other_user, from_user: user.id)
      }.to raise_error(ReturningError::Unauthorized, "User #{other_user.id} is not authorized to return device #{serial_number}.")
    end

    it 'raises an Unauthorized error when the from_user does not match the user\'s id' do
      expect {
        return_device(from_user: other_user.id)
      }.to raise_error(ReturningError::Unauthorized, "User #{user.id} is not authorized to return device #{serial_number}.")
    end
  end

  context 'when the user has previously returned the device' do
    before do
      AssignDeviceToUser.new(
        requesting_user: user,
        serial_number: serial_number,
        new_device_owner_id: user.id
      ).call

      return_device
    end

    it 'does not allow the user to re-assign the same device' do
      expect {
        AssignDeviceToUser.new(
          requesting_user: user,
          serial_number: serial_number,
          new_device_owner_id: user.id
        ).call
      }.to raise_error(AssigningError::AlreadyUsedOnUser)
    end
  end
end
