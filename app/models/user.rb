class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true

  has_many :tickets
  has_many :events, through: :tickets
end
