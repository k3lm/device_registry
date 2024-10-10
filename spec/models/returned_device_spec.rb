require 'rails_helper'

RSpec.describe ReturnedDevice, type: :model do
  let(:user) { create(:user) }
  let(:device) { create(:device, user: user) }
  let(:returned_device) { create(:returned_device, user: user, device: device) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:device) }
  end
end