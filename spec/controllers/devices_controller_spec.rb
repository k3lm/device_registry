# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DevicesController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:device) { create(:device, user: user) }
  let(:serial_number) { device.serial_number }
  let(:api_key) { create(:api_key, bearer: user) }

  before do
    request.headers['Authorization'] = "Bearer #{api_key.token}"
    allow(controller).to receive(:authenticate_user!).and_call_original
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'POST #assign' do
    context 'when the user is authenticated' do
      context 'when a user tries to register a device that was already assigned to and returned by the same user' do
        before do
          ReturnedDevice.create!(user: user, device: device)
        end

        it 'does not allow to register' do
          post :assign, params: { device: { serial_number: serial_number, new_owner_id: user.id } }
          expect(response).to have_http_status(422) # Unprocessable Entity
          expect(JSON.parse(response.body)['error']).to include('User has previously returned a device with serial number')
        end
      end

      context 'when user tries to register a device that is already assigned to another user' do
        before do
          device.update!(user: other_user)
        end

        it 'does not allow to register' do
          post :assign, params: { device: { serial_number: serial_number, new_owner_id: user.id } }
          expect(response).to have_http_status(422) # Unprocessable Entity
          expect(JSON.parse(response.body)['error']).to include('is already assigned to another user')
        end
      end
    end
  end

  describe 'POST #unassign' do
    context 'when the user is authenticated' do
      context 'when user unassigns a device from another user' do
        before do
          device.update!(user: other_user)
        end

        it 'returns an unauthorized response' do
          post :unassign, params: { device: { serial_number: serial_number } }
          expect(response).to have_http_status(401) # Unauthorized
          expect(JSON.parse(response.body)['error']).to include('not authorized to return device')
        end
      end

      context 'when user unassigns a device from self' do
        it 'returns a success response' do
          post :unassign, params: { device: { serial_number: serial_number } }
          expect(response).to have_http_status(200) # OK
        end

        it 'prevents re-assigning the same device to self' do
          post :unassign, params: { device: { serial_number: serial_number } }
          post :assign, params: { device: { serial_number: serial_number, new_owner_id: user.id } }
          expect(response).to have_http_status(422) # Unprocessable Entity
          expect(JSON.parse(response.body)['error']).to include("User has previously returned a device with serial number #{serial_number}")
        end
      end
    end

    context 'when the user is not authenticated' do
      before do
        request.headers['Authorization'] = nil
        allow(controller).to receive(:authenticate_user!).and_call_original
      end

      it 'returns an unauthorized response' do
        post :unassign, params: { device: { serial_number: serial_number } }
        expect(response).to have_http_status(401) # Unauthorized
      end
    end
  end
end