require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe 'validations' do
    let(:event) { create(:event) }
    let(:user) { create(:user) }

    it 'is valid with required attributes' do
      expect(build(:ticket, event: event, user: user)).to be_valid
    end

    it 'requires an event' do
      ticket = build(:ticket, event: nil, user: user)

      expect(ticket).not_to be_valid
      expect(ticket.errors[:event]).to include('must exist')
      expect(ticket.errors[:event_id]).to include("can't be blank")
    end

    it 'requires a user' do
      ticket = build(:ticket, event: event, user: nil)

      expect(ticket).not_to be_valid
      expect(ticket.errors[:user]).to include('must exist')
      expect(ticket.errors[:user_id]).to include("can't be blank")
    end
  end
end
