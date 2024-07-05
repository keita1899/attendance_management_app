require "rails_helper"

RSpec.describe Attendance, type: :model do
  let!(:user) { create(:user) }
  let!(:attendance) { build(:attendance, user:) }

  describe "#update_attendance_data" do
    context "平日の場合" do
      before do
        allow(attendance).to receive(:calculate_working_minutes).and_return(240)
        allow(attendance).to receive(:calculate_overtime_minutes).and_return(0)
        allow(attendance).to receive(:calculate_total_working_minutes).and_return(240)
        allow(attendance).to receive(:set_hourly_wage).and_return(1000)
        allow(attendance).to receive(:calculate_daily_wage).and_return(4000)
        allow(attendance).to receive(:calculate_overtime_pay).and_return(0)
        allow(attendance).to receive(:calculate_daily_total_payment).and_return(4320)
      end

      it "正しく更新される" do
        attendance.update_attendance_data

        expect(attendance.working_minutes).to eq(240)
        expect(attendance.overtime_minutes).to eq(0)
        expect(attendance.total_working_minutes).to eq(240)
        expect(attendance.hourly_wage).to eq(1000)
        expect(attendance.daily_wage).to eq(4000)
        expect(attendance.overtime_pay).to eq(0)
        expect(attendance.transport_cost).to eq(TRANSPORT_COST)
        expect(attendance.allowance).to eq(0)
        expect(attendance.total_payment).to eq(4320)
      end
    end

    context "土日の場合" do
      before do
        allow(attendance).to receive(:calculate_working_minutes).and_return(240)
        allow(attendance).to receive(:calculate_overtime_minutes).and_return(0)
        allow(attendance).to receive(:calculate_total_working_minutes).and_return(240)
        allow(attendance).to receive(:set_hourly_wage).and_return(1100)
        allow(attendance).to receive(:calculate_daily_wage).and_return(4400)
        allow(attendance).to receive(:calculate_overtime_pay).and_return(0)
        allow(attendance).to receive(:calculate_daily_total_payment).and_return(4720)
      end

      it "正しく更新される" do
        attendance.update_attendance_data

        expect(attendance.working_minutes).to eq(240)
        expect(attendance.overtime_minutes).to eq(0)
        expect(attendance.total_working_minutes).to eq(240)
        expect(attendance.hourly_wage).to eq(1100)
        expect(attendance.daily_wage).to eq(4400)
        expect(attendance.overtime_pay).to eq(0)
        expect(attendance.transport_cost).to eq(TRANSPORT_COST)
        expect(attendance.allowance).to eq(0)
        expect(attendance.total_payment).to eq(4720)
      end
    end

    context "平日かつ特別日の場合" do
      let!(:attendance) { build(:attendance, user:, special_day: true) }

      before do
        allow(attendance).to receive(:calculate_working_minutes).and_return(240)
        allow(attendance).to receive(:calculate_overtime_minutes).and_return(0)
        allow(attendance).to receive(:calculate_total_working_minutes).and_return(240)
        allow(attendance).to receive(:set_hourly_wage).and_return(1100)
        allow(attendance).to receive(:calculate_daily_wage).and_return(4400)
        allow(attendance).to receive(:calculate_overtime_pay).and_return(0)
        allow(attendance).to receive(:set_allowance).and_return(1500)
        allow(attendance).to receive(:calculate_daily_total_payment).and_return(6220)
      end

      it "正しく更新される" do
        attendance.update_attendance_data

        expect(attendance.working_minutes).to eq(240)
        expect(attendance.overtime_minutes).to eq(0)
        expect(attendance.total_working_minutes).to eq(240)
        expect(attendance.hourly_wage).to eq(1100)
        expect(attendance.daily_wage).to eq(4400)
        expect(attendance.overtime_pay).to eq(0)
        expect(attendance.transport_cost).to eq(TRANSPORT_COST)
        expect(attendance.allowance).to eq(1500)
        expect(attendance.total_payment).to eq(6220)
      end
    end
  end

  describe "#special_day?" do
    context "出勤日が特別日の場合" do
      let!(:attendance) { build(:attendance, user:, special_day: true) }

      it "trueを返す" do
        expect(attendance.special_day?).to be true
      end
    end

    context "出勤日が特別日ではない場合" do
      let!(:attendance) { build(:attendance, user:, special_day: false) }

      it "falseを返す" do
        expect(attendance.special_day?).to be false
      end
    end
  end
end
