# frozen_string_literal: true

class DevicesController < ApplicationController
  before_action :authenticate_user!, only: %i[assign unassign]

  def assign
    AssignDeviceToUser.new(
      requesting_user: @current_user,
      serial_number: device_params[:serial_number],
      new_device_owner_id: device_params[:new_owner_id]
    ).call
    head :ok
  rescue RegistrationError::Unauthorized => e
    render json: { error: e.message }, status: :unauthorized
  rescue AssigningError::AlreadyUsedOnUser => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue AssigningError::AlreadyUsedOnOtherUser => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def unassign
    ReturnDeviceFromUser.new(
      user: @current_user,
      serial_number: device_params[:serial_number],
      from_user: @current_user.id
    ).call
    head :ok
  rescue ReturningError::Unauthorized => e
    render json: { error: e.message }, status: :unauthorized
  rescue ReturningError::DeviceNotFound => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def device_params
    params.require(:device).permit(:new_owner_id, :serial_number)
  end
end