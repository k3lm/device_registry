require 'rails_helper'

RSpec.describe Device, type: :model do
  let(:user) { create(:user) }
  let!(:device) { create(:device, user: user) }

  describe 'validations' do
    it { should validate_presence_of(:serial_number) }
    it { should validate_uniqueness_of(:serial_number) }
  end

  describe 'associations' do
    it { should belong_to(:user).optional }
    it { should have_many(:returned_devices).dependent(:destroy) }
    it { should have_many(:users_returned).through(:returned_devices).source(:user) }
  end
end