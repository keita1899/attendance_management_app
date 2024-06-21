require "rails_helper"

RSpec.describe AttendanceSummaryService, type: :service do
  let!(:user) { create(:user) }
  let(:service) { AttendanceSummaryService.new(user, target_month) }
  let!(:target_month) { Date.new(2024, 5, 1) }
  let!(:start_date) { Date.new(2024, 4, 21) }
  let!(:end_date) { Date.new(2024, 5, 20) }
  let!(:transport_cost) { 320 }

  def create_weekday_attendance(user)
    create(:attendance, user:, date: start_date + 1.day, working_minutes: 240, overtime_minutes: 0, daily_wage: 4000, overtime_pay: 0) # 2024-04-22 (月曜日)
    create(:attendance, user:, date: start_date + 2.days, working_minutes: 240, overtime_minutes: 60, daily_wage: 4000, overtime_pay: 1000) # 2024-04-23 (火曜日)
  end

  def create_weekend_attendance(user)
    create(:attendance, user:, date: start_date + 6.days, working_minutes: 240, overtime_minutes: 0, daily_wage: 4400, overtime_pay: 0) # 2024-04-27 (土曜日)
    create(:attendance, user:, date: start_date + 7.days, working_minutes: 240, overtime_minutes: 60, daily_wage: 4400, overtime_pay: 1100) # 2024-04-28 (日曜日)
  end

  before do
    create_weekday_attendance(user)
    create_weekend_attendance(user)
  end

  describe "#total_monthly_working_weekdays" do
    it "平日の合計出勤日数を返す" do
      expect(service.total_monthly_working_weekdays).to eq(2)
    end
  end

  describe "#total_monthly_working_weekends" do
    it "土日の合計出勤日数を返す" do
      expect(service.total_monthly_working_weekends).to eq(2)
    end
  end

  describe "#total_monthly_working_days" do
    it "合計出勤日数を返す" do
      expect(service.total_monthly_working_days).to eq(4)
    end
  end

  describe "#total_monthly_weekday_working_minutes" do
    it "平日の合計出勤時間を返す" do
      expect(service.total_monthly_weekday_working_minutes).to eq(480)
    end
  end

  describe "#total_monthly_weekend_working_minutes" do
    it "土日の合計出勤時間を返す" do
      expect(service.total_monthly_weekend_working_minutes).to eq(480)
    end
  end

  describe "#total_monthly_working_minutes" do
    it "合計出勤時間を返す" do
      expect(service.total_monthly_working_minutes).to eq(960)
    end
  end

  describe "#total_monthly_weekday_overtime_minutes" do
    it "平日の合計残業時間を返す" do
      expect(service.total_monthly_weekday_overtime_minutes).to eq(60)
    end
  end

  describe "#total_monthly_weekend_overtime_minutes" do
    it "土日の合計残業時間を返す" do
      expect(service.total_monthly_weekend_overtime_minutes).to eq(60)
    end
  end

  describe "#total_monthly_overtime_minutes" do
    it "合計残業時間を返す" do
      expect(service.total_monthly_overtime_minutes).to eq(120)
    end
  end

  describe "#total_monthly_weekday_daily_wage" do
    it "平日の合計基本給を返す" do
      expect(service.total_monthly_weekday_daily_wage).to eq(8000)
    end
  end

  describe "#total_monthly_weekend_daily_wage" do
    it "土日の合計基本給を返す" do
      expect(service.total_monthly_weekend_daily_wage).to eq(8800)
    end
  end

  describe "#total_monthly_daily_wage" do
    it "合計基本給を返す" do
      expect(service.total_monthly_daily_wage).to eq(16800)
    end
  end

  describe "#total_monthly_weekday_overtime_pay" do
    it "平日の合計残業代を返す" do
      expect(service.total_monthly_weekday_overtime_pay).to eq(1000)
    end
  end

  describe "#total_monthly_weekend_overtime_pay" do
    it "土日の合計残業代を返す" do
      expect(service.total_monthly_weekend_overtime_pay).to eq(1100)
    end
  end

  describe "#total_monthly_overtime_pay" do
    it "合計残業代を返す" do
      expect(service.total_monthly_overtime_pay).to eq(2100)
    end
  end

  describe "#total_monthly_transport_cost" do
    it "合計交通費を返す" do
      expect(service.total_monthly_transport_cost).to eq(transport_cost * 4)
    end
  end

  describe "#total_monthly_payment" do
    it "総支給額を返す" do
      expect(service.total_monthly_payment).to eq(20180)
    end
  end
end
