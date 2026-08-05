class Event < ApplicationRecord
  validates :name, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :max_capacity, presence: true, numericality: { greater_than: 0 }

  has_many :tickets
  has_many :users, through: :tickets

  def tickets_sold
    tickets.count
  end

  def sold_out?
    max_capacity <= tickets_sold
  end
end
