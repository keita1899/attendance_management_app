class SpecialDay < ApplicationRecord
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :description, presence: true, length: { maximum: 30 }
  validates :wage_increment, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :allowance, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :start_date_before_end_date
  validate :no_overlapping_dates

  def self.in_month(date)
    start_date = date.beginning_of_month
    end_date = date.end_of_month
    where("start_date <= ? AND end_date >= ?", end_date, start_date)
  end

  private

    def start_date_before_end_date
      if start_date.present? && end_date.present?
        errors.add(:start_date, "は終了日より前でなければなりません") if start_date > end_date
        errors.add(:end_date, "は開始日より後でなければなりません") if end_date < start_date
      end
    end

    def no_overlapping_dates
      if SpecialDay.exists?(["(start_date <= ? AND end_date >= ?) OR (start_date <= ? AND end_date >= ?) OR (start_date >= ? AND end_date <= ?)", start_date,
                             start_date, end_date, end_date, start_date, end_date])
        errors.add(:base, "既存の特別日と日付が重複しています")
      end
    end
end
