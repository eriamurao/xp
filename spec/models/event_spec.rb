require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'validations' do
    it 'is valid with required attributes' do
      expect(build(:event)).to be_valid
    end

    it 'requires name' do
      event = build(:event, name: nil)

      expect(event).not_to be_valid
      expect(event.errors[:name]).to include("can't be blank")
    end

    it 'requires start_time' do
      event = build(:event, start_time: nil)

      expect(event).not_to be_valid
      expect(event.errors[:start_time]).to include("can't be blank")
    end

    it 'requires end_time' do
      event = build(:event, end_time: nil)

      expect(event).not_to be_valid
      expect(event.errors[:end_time]).to include("can't be blank")
    end

    it 'requires max_capacity' do
      event = build(:event, max_capacity: nil)

      expect(event).not_to be_valid
      expect(event.errors[:max_capacity]).to include("can't be blank")
    end

    it 'requires max_capacity to be greater than 0' do
      event = build(:event, max_capacity: 0)

      expect(event).not_to be_valid
      expect(event.errors[:max_capacity]).to include('must be greater than 0')
    end
  end
end
