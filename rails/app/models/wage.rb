class Wage < ApplicationRecord
  belongs_to :user, touch: true

  validates :weekday_rate, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :weekend_rate, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
