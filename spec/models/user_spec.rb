require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it { should have_many(:devices) }
    it { should have_many(:returned_devices) }
  end
end