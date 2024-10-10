# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignDeviceToUser do
  let(:user) { create(:user) }
  let(:serial_number) { '123456' }

  def assign_device(requesting_user: user, device_serial_number: serial_number, new_device_owner_id: user.id)
    AssignDeviceToUser.new(
      requesting_user: requesting_user,
      serial_number: device_serial_number,
      new_device_owner_id: new_device_owner_id
    ).call
  end

  context 'when user registers a device to another user' do
    let(:new_device_owner_id) { create(:user).id }

    it 'raises an unauthorized error' do
      expect {
        assign_device(new_device_owner_id: new_device_owner_id)
      }.to raise_error(RegistrationError::Unauthorized)
    end
  end

  context 'when user registers a device on self' do
    let(:new_device_owner_id) { user.id }

    it 'creates a new device' do
      assign_device

      expect(user.devices.pluck(:serial_number)).to include(serial_number)
    end

    context 'when a user tries to register a device that was already assigned to and returned by the same user' do
      before do
        assign_device
        ReturnDeviceFromUser.new(user: user, serial_number: serial_number, from_user: user.id).call
      end

      it 'does not allow to register' do
        expect {
          assign_device
        }.to raise_error(AssigningError::AlreadyUsedOnUser)
      end
    end

    context 'when user tries to register a device that is already assigned to another user' do
      let(:other_user) { create(:user) }

      before do
        assign_device(requesting_user: other_user, new_device_owner_id: other_user.id)
      end

      it 'does not allow to register' do
        expect {
          assign_device
        }.to raise_error(AssigningError::AlreadyUsedOnOtherUser)
      end
    end
  end
end
