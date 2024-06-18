require 'rails_helper'

RSpec.describe Attendance, type: :model do
  let!(:user) { create(:user) }
  let!(:attendance) { build(:attendance, user: user) }

  describe '#update_attendance_data' do
    context '平日の場合' do
      before do
        allow(attendance).to receive(:calculate_working_minutes).and_return(240)
        allow(attendance).to receive(:calculate_overtime_minutes).and_return(0)
        allow(attendance).to receive(:calculate_total_working_minutes).and_return(240)
        allow(attendance).to receive(:set_hourly_wage).and_return(1000)
        allow(attendance).to receive(:calculate_daily_wage).and_return(4000)
        allow(attendance).to receive(:calculate_overtime_pay).and_return(0)
        allow(attendance).to receive(:calculate_daily_total_payment).and_return(4320)
      end
  
      it '正しく更新される' do
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

    context '土日の場合' do
      before do
        allow(attendance).to receive(:calculate_working_minutes).and_return(240)
        allow(attendance).to receive(:calculate_overtime_minutes).and_return(0)
        allow(attendance).to receive(:calculate_total_working_minutes).and_return(240)
        allow(attendance).to receive(:set_hourly_wage).and_return(1100)
        allow(attendance).to receive(:calculate_daily_wage).and_return(4400)
        allow(attendance).to receive(:calculate_overtime_pay).and_return(0)
        allow(attendance).to receive(:calculate_daily_total_payment).and_return(4720)
      end
  
      it '正しく更新される' do
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
  end

  describe '#convert_minutes_to_hour' do
    let!(:attendance) { build(:attendance, user: user) }

    it '60分を1時間に変換する' do
      expect(attendance.send(:convert_minutes_to_hour, 60)).to eq(1)
    end

    it '120分を2時間に変換する' do
      expect(attendance.send(:convert_minutes_to_hour, 120)).to eq(2)
    end

    it '90分を1時間に変換する' do
      expect(attendance.send(:convert_minutes_to_hour, 90)).to eq(1)
    end

    it '0分を0時間に変換する' do
      expect(attendance.send(:convert_minutes_to_hour, 0)).to eq(0)
    end

    it '30分を0時間に変換する' do
      expect(attendance.send(:convert_minutes_to_hour, 30)).to eq(0)
    end
  end

  describe '#convert_seconds_to_minutes' do
    let!(:attendance) { create(:attendance, user: user) }

    it '60秒を1分に変換する' do
      expect(attendance.send(:convert_seconds_to_minutes, 60)).to eq(1)
    end

    it '120秒を2分に変換する' do
      expect(attendance.send(:convert_seconds_to_minutes, 120)).to eq(2)
    end

    it '90秒を1分に変換する' do
      expect(attendance.send(:convert_seconds_to_minutes, 90)).to eq(1)
    end

    it '0秒を0分に変換する' do
      expect(attendance.send(:convert_seconds_to_minutes, 0)).to eq(0)
    end

    it '30秒を0分に変換する' do
      expect(attendance.send(:convert_seconds_to_minutes, 30)).to eq(0)
    end

    it '59秒を0分に変換する' do
      expect(attendance.send(:convert_seconds_to_minutes, 30)).to eq(0)
    end
  end

  describe '#set_hourly_wage' do
    context '平日の場合' do
      let!(:attendance) { build(:attendance, user: user) }

      it '平日の時給を返す' do
        expect(attendance.send(:set_hourly_wage)).to eq(user.wage.weekday_hourly_wage)
      end
    end

    context '土日の場合' do
      let!(:saturday_attendance) { build(:saturday_attendance, user: user) }

      it '土曜日の時給を返す' do
        expect(saturday_attendance.send(:set_hourly_wage)).to eq(user.wage.weekend_hourly_wage)
      end
    end
      
    context '日曜日の場合' do
      let!(:sunday_attendance) { build(:sunday_attendance, user: user) }

      it '日曜日の時給を返す' do
        expect(sunday_attendance.send(:set_hourly_wage)).to eq(user.wage.weekend_hourly_wage)
      end
    end
  end

  describe '#is_weekend?' do
    context '平日の場合' do
      let!(:attendance) { build(:attendance, user: user) }
    
      it 'falseを返す' do
        expect(attendance.send(:is_weekend?)).to be(false)
      end
    end
      
    context '土曜日の場合' do
      let!(:saturday_attendance) { build(:saturday_attendance, user: user) }
      
      it 'trueを返す' do
        expect(saturday_attendance.send(:is_weekend?)).to be(true)
      end
    end
        
    context '日曜日の場合' do
      let!(:sunday_attendance) { build(:sunday_attendance, user: user) }
      it 'trueを返す' do
        expect(sunday_attendance.send(:is_weekend?)).to be(true)
      end
    end
  end

  describe '#calculate_working_minutes' do
    context '13:00に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1300, user: user) }
      it '180分を返す' do
        expect(attendance.send(:calculate_working_minutes)).to eq(180)
      end
    end

    context '14:01に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1401, user: user) }
      it '240分を返す' do
        expect(attendance.send(:calculate_working_minutes)).to eq(240)
      end
    end

    context '14:30に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1430, user: user) }
      it '240分を返す' do
        expect(attendance.send(:calculate_working_minutes)).to eq(240)
      end
    end

    context '15:00に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1500, user: user) }
      it '240分を返す' do
        expect(attendance.send(:calculate_working_minutes)).to eq(240)
      end
    end
  end

  describe '#calculate_overtime_minutes' do
    context '13:00に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1300, user: user) }
      it '0分を返す' do
        expect(attendance.send(:calculate_overtime_minutes)).to eq(0)
      end
    end

    context '14:01に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1401, user: user) }
      it '1分を返す' do
        expect(attendance.send(:calculate_overtime_minutes)).to eq(1)
      end
    end

    context '14:29に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1429, user: user) }
      it '29分を返す' do
        expect(attendance.send(:calculate_overtime_minutes)).to eq(29)
      end
    end

    context '14:30に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1430, user: user) }
      it '30分を返す' do
        expect(attendance.send(:calculate_overtime_minutes)).to eq(30)
      end
    end

    context '14:31に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1431, user: user) }
      it '31分を返す' do
        expect(attendance.send(:calculate_overtime_minutes)).to eq(31)
      end
    end

    context '14:59に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1459, user: user) }
      it '59分を返す' do
        expect(attendance.send(:calculate_overtime_minutes)).to eq(59)
      end
    end

    context '15:00に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1500, user: user) }
      it '60分を返す' do
        expect(attendance.send(:calculate_overtime_minutes)).to eq(60)
      end
    end
  end

  describe '#calculate_total_working_minutes' do
    context '13:00に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1300, user: user) }
      it '180分を返す' do
        expect(attendance.send(:calculate_total_working_minutes)).to eq(180)
      end
    end

    context '14:01に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1401, user: user) }
      it '241分を返す' do
        expect(attendance.send(:calculate_total_working_minutes)).to eq(241)
      end
    end

    context '14:29に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1429, user: user) }
      it '269分を返す' do
        expect(attendance.send(:calculate_total_working_minutes)).to eq(269)
      end
    end

    context '14:30に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1430, user: user) }
      it '270分を返す' do
        expect(attendance.send(:calculate_total_working_minutes)).to eq(270)
      end
    end

    context '14:31に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1431, user: user) }
      it '271分を返す' do
        expect(attendance.send(:calculate_total_working_minutes)).to eq(271)
      end
    end

    context '14:59に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1459, user: user) }
      it '299分を返す' do
        expect(attendance.send(:calculate_total_working_minutes)).to eq(299)
      end
    end

    context '15:00に退勤した場合' do
      let!(:attendance) { build(:attendance, :clock_out_1500, user: user) }
      it '300分を返す' do
        expect(attendance.send(:calculate_total_working_minutes)).to eq(300)
      end
    end
  end

  describe '#calculate_daily_wage' do
    context '平日の場合' do
      context '13:00に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1300, user: user) }

        it '4000を返す' do
          expect(attendance.send(:calculate_daily_wage)).to eq(4000)
        end
      end

      context '14:00に退勤した場合' do
        let!(:attendance) { build(:attendance, user: user) }

        it '4000を返す' do
          expect(attendance.send(:calculate_daily_wage)).to eq(4000)
        end
      end

      context '15:00に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1500, user: user) }

        it '4000を返す' do
          expect(attendance.send(:calculate_daily_wage)).to eq(4000)
        end
      end
    end

    context '土曜日の場合' do
      context '13:00に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1300, user: user) }

        it '4400を返す' do
          expect(saturday_attendance.send(:calculate_daily_wage)).to eq(4400)
        end
      end

      context '14:00に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, user: user) }

        it '4400を返す' do
          expect(saturday_attendance.send(:calculate_daily_wage)).to eq(4400)
        end
      end

      context '15:00に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1500, user: user) }

        it '4400を返す' do
          expect(saturday_attendance.send(:calculate_daily_wage)).to eq(4400)
        end
      end
    end

    context '日曜日の場合' do
      context '13:00に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1300, user: user) }

        it '4400を返す' do
          expect(sunday_attendance.send(:calculate_daily_wage)).to eq(4400)
        end
      end

      context '14:00に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, user: user) }

        it '4400を返す' do
          expect(sunday_attendance.send(:calculate_daily_wage)).to eq(4400)
        end
      end

      context '15:00に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1500, user: user) }

        it '4400を返す' do
          expect(sunday_attendance.send(:calculate_daily_wage)).to eq(4400)
        end
      end
    end
  end

  describe '#calculate_overtime_pay' do
    context '平日の場合' do
      context '13:00に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1300, user: user) }

        it '0を返す' do
          expect(attendance.send(:calculate_overtime_pay)).to eq(0)
        end
      end

      context '14:00に退勤した場合' do
        let!(:attendance) { build(:attendance, user: user) }

        it '0を返す' do
          expect(attendance.send(:calculate_overtime_pay)).to eq(0)
        end
      end

      context '14:01に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1401, user: user) }

        it '0を返す' do
          expect(attendance.send(:calculate_overtime_pay)).to eq(0)
        end
      end

      context '14:29に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1429, user: user) }

        it '0を返す' do
          expect(attendance.send(:calculate_overtime_pay)).to eq(0)
        end
      end

      context '14:30に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1430, user: user) }

        it '500を返す' do
          expect(attendance.send(:calculate_overtime_pay)).to eq(500)
        end
      end

      context '14:31に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1431, user: user) }

        it '500を返す' do
          expect(attendance.send(:calculate_overtime_pay)).to eq(500)
        end
      end

      context '14:59に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1459, user: user) }

        it '500を返す' do
          expect(attendance.send(:calculate_overtime_pay)).to eq(500)
        end
      end

      context '15:00に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1500, user: user) }

        it '1000を返す' do
          expect(attendance.send(:calculate_overtime_pay)).to eq(1000)
        end
      end
    end

    context '土曜日の場合' do
      context '13:00に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1300, user: user) }

        it '0を返す' do
          expect(saturday_attendance.send(:calculate_overtime_pay)).to eq(0)
        end
      end

      context '14:00に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, user: user) }

        it '0を返す' do
          expect(saturday_attendance.send(:calculate_overtime_pay)).to eq(0)
        end
      end

      context '14:01に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1401, user: user) }

        it '0を返す' do
          expect(saturday_attendance.send(:calculate_overtime_pay)).to eq(0)
        end
      end

      context '14:29に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1429, user: user) }

        it '0を返す' do
          expect(saturday_attendance.send(:calculate_overtime_pay)).to eq(0)
        end
      end

      context '14:30に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1430, user: user) }

        it '550を返す' do
          expect(saturday_attendance.send(:calculate_overtime_pay)).to eq(550)
        end
      end

      context '14:31に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1431, user: user) }

        it '550を返す' do
          expect(saturday_attendance.send(:calculate_overtime_pay)).to eq(550)
        end
      end

      context '14:59に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1459, user: user) }

        it '550を返す' do
          expect(saturday_attendance.send(:calculate_overtime_pay)).to eq(550)
        end
      end

      context '15:00に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1500, user: user) }

        it '1100を返す' do
          expect(saturday_attendance.send(:calculate_overtime_pay)).to eq(1100)
        end
      end
    end

    context '日曜日の場合' do
      context '13:00に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1300, user: user) }

        it '0を返す' do
          expect(sunday_attendance.send(:calculate_overtime_pay)).to eq(0)
        end
      end

      context '14:00に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, user: user) }

        it '0を返す' do
          expect(sunday_attendance.send(:calculate_overtime_pay)).to eq(0)
        end
      end

      context '14:01に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1401, user: user) }

        it '0を返す' do
          expect(sunday_attendance.send(:calculate_overtime_pay)).to eq(0)
        end
      end

      context '14:29に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1429, user: user) }

        it '0を返す' do
          expect(sunday_attendance.send(:calculate_overtime_pay)).to eq(0)
        end
      end

      context '14:30に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1430, user: user) }

        it '550を返す' do
          expect(sunday_attendance.send(:calculate_overtime_pay)).to eq(550)
        end
      end

      context '14:31に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1431, user: user) }

        it '550を返す' do
          expect(sunday_attendance.send(:calculate_overtime_pay)).to eq(550)
        end
      end

      context '14:59に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1459, user: user) }

        it '550を返す' do
          expect(sunday_attendance.send(:calculate_overtime_pay)).to eq(550)
        end
      end

      context '15:00に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1500, user: user) }

        it '1100を返す' do
          expect(sunday_attendance.send(:calculate_overtime_pay)).to eq(1100)
        end
      end
    end
  end

  describe '#calculate_daily_total_payment' do
    context '平日の場合' do
      context '13:00に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1300, user: user) }

        it '4320を返す' do
          expect(attendance.send(:calculate_daily_total_payment)).to eq(4320)
        end
      end

      context '14:00に退勤した場合' do
        let!(:attendance) { build(:attendance, user: user) }

        it '4320を返す' do
          expect(attendance.send(:calculate_daily_total_payment)).to eq(4320)
        end
      end

      context '14:01に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1401, user: user) }

        it '4320を返す' do
          expect(attendance.send(:calculate_daily_total_payment)).to eq(4320)
        end
      end

      context '14:29に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1429, user: user) }

        it '4320を返す' do
          expect(attendance.send(:calculate_daily_total_payment)).to eq(4320)
        end
      end

      context '14:30に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1430, user: user) }

        it '4820を返す' do
          expect(attendance.send(:calculate_daily_total_payment)).to eq(4820)
        end
      end

      context '14:31に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1431, user: user) }

        it '4820を返す' do
          expect(attendance.send(:calculate_daily_total_payment)).to eq(4820)
        end
      end

      context '14:59に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1459, user: user) }

        it '4820を返す' do
          expect(attendance.send(:calculate_daily_total_payment)).to eq(4820)
        end
      end

      context '15:00に退勤した場合' do
        let!(:attendance) { build(:attendance, :clock_out_1500, user: user) }

        it '5320を返す' do
          expect(attendance.send(:calculate_daily_total_payment)).to eq(5320)
        end
      end
    end

    context '土曜日の場合' do
      context '13:00に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1300, user: user) }

        it '4720を返す' do
          expect(saturday_attendance.send(:calculate_daily_total_payment)).to eq(4720)
        end
      end

      context '14:00に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, user: user) }

        it '4720を返す' do
          expect(saturday_attendance.send(:calculate_daily_total_payment)).to eq(4720)
        end
      end

      context '14:01に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1401, user: user) }

        it '4720を返す' do
          expect(saturday_attendance.send(:calculate_daily_total_payment)).to eq(4720)
        end
      end

      context '14:29に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1429, user: user) }

        it '4720を返す' do
          expect(saturday_attendance.send(:calculate_daily_total_payment)).to eq(4720)
        end
      end

      context '14:30に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1430, user: user) }

        it '5270を返す' do
          expect(saturday_attendance.send(:calculate_daily_total_payment)).to eq(5270)
        end
      end

      context '14:31に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1431, user: user) }

        it '5270を返す' do
          expect(saturday_attendance.send(:calculate_daily_total_payment)).to eq(5270)
        end
      end

      context '14:59に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1459, user: user) }

        it '5270を返す' do
          expect(saturday_attendance.send(:calculate_daily_total_payment)).to eq(5270)
        end
      end

      context '15:00に退勤した場合' do
        let!(:saturday_attendance) { build(:saturday_attendance, :clock_out_1500, user: user) }

        it '5820を返す' do
          expect(saturday_attendance.send(:calculate_daily_total_payment)).to eq(5820)
        end
      end
    end

    context '日曜日の場合' do
      context '13:00に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1300, user: user) }

        it '4720を返す' do
          expect(sunday_attendance.send(:calculate_daily_total_payment)).to eq(4720)
        end
      end

      context '14:00に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, user: user) }

        it '4720を返す' do
          expect(sunday_attendance.send(:calculate_daily_total_payment)).to eq(4720)
        end
      end

      context '14:01に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1401, user: user) }

        it '4720を返す' do
          expect(sunday_attendance.send(:calculate_daily_total_payment)).to eq(4720)
        end
      end

      context '14:29に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1429, user: user) }

        it '4720を返す' do
          expect(sunday_attendance.send(:calculate_daily_total_payment)).to eq(4720)
        end
      end

      context '14:30に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1430, user: user) }

        it '5270を返す' do
          expect(sunday_attendance.send(:calculate_daily_total_payment)).to eq(5270)
        end
      end

      context '14:31に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1431, user: user) }

        it '5270を返す' do
          expect(sunday_attendance.send(:calculate_daily_total_payment)).to eq(5270)
        end
      end

      context '14:59に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1459, user: user) }

        it '5270を返す' do
          expect(sunday_attendance.send(:calculate_daily_total_payment)).to eq(5270)
        end
      end

      context '15:00に退勤した場合' do
        let!(:sunday_attendance) { build(:sunday_attendance, :clock_out_1500, user: user) }

        it '5820を返す' do
          expect(sunday_attendance.send(:calculate_daily_total_payment)).to eq(5820)
        end
      end
    end
  end
end
