require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with required attributes' do
      expect(build(:user)).to be_valid
    end

    it 'requires email' do
      user = build(:user, email: nil)

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'requires email to be unique' do
      create(:user, email: 'same@example.com')
      duplicate = build(:user, email: 'same@example.com')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include('has already been taken')
    end
  end
end
