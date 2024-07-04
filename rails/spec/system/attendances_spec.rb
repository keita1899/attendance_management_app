require "rails_helper"

RSpec.describe "Attendances", type: :system do
  before do
    driven_by(:rack_test)
  end

  let!(:user) { create(:user) }
  let!(:attendance) { create(:attendance, user:) }

  def create_weekday_attendance
    create(:attendance, user:, date: start_date + 1.day, working_minutes: 240, overtime_minutes: 0, daily_wage: 4000, overtime_pay: 0) # 2024-04-22 (月曜日)
    create(:attendance, user:, date: start_date + 2.days, working_minutes: 240, overtime_minutes: 60, daily_wage: 4000, overtime_pay: 1000) # 2024-04-23 (火曜日)
  end

  def create_weekend_attendance
    create(:attendance, user:, date: start_date + 6.days, working_minutes: 240, overtime_minutes: 0, daily_wage: 4400, overtime_pay: 0) # 2024-04-27 (土曜日)
    create(:attendance, user:, date: start_date + 7.days, working_minutes: 240, overtime_minutes: 60, daily_wage: 4400, overtime_pay: 1100) # 2024-04-28 (日曜日)
  end

  def create_special_day_attendance
    create(:attendance, user:, date: start_date + 8.days, working_minutes: 240, overtime_minutes: 0, daily_wage: 4400, overtime_pay: 0, allowance: 1500,
                        special_day: true)
    create(:attendance, user:, date: start_date + 9.days, working_minutes: 240, overtime_minutes: 60, daily_wage: 4400, overtime_pay: 1100, allowance: 1500,
                        special_day: true)
  end

  describe "カレンダーページ表示" do
    context "未ログインの場合" do
      it "ログイン画面にリダイレクトされる" do
        visit attendances_path

        expect(page).to have_current_path(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      let!(:target_month) { Date.new(2024, 5, 1) }
      let!(:start_date) { Date.new(2024, 4, 21) }
      let!(:end_date) { Date.new(2024, 5, 20) }
      let!(:transport_cost) { 320 }
      let!(:special_day) { create(:special_day, start_date: Date.new(2024, 4, 29), end_date: Date.new(2024, 5, 5), description: "GW") }

      before do
        create_weekday_attendance
        create_weekend_attendance
        create_special_day_attendance
        sign_in user

        visit attendances_path(start_date: target_month)
      end

      it "5月のカレンダーページが表示される" do
        expect(page).to have_content "4/21 ~ 5/20"
        expect(page).to have_title "カレンダー"
      end

      it "カレンダーの日付に特別日の説明が表示される" do
        expect(page).to have_content "GW"
      end

      it "合計勤務日数が表示される" do
        expect(page).to have_content "勤務日数"
        expect(page).to have_content "平日勤務日数 2日"
        expect(page).to have_content "土日・祝日勤務日数 2日"
        expect(page).to have_content "特別日勤務日数 2日"
        expect(page).to have_content "合計勤務日数 6日"
      end

      it "合計勤務時間が表示される" do
        expect(page).to have_content "勤務時間"
        expect(page).to have_content "平日勤務時間 8時間 0分"
        expect(page).to have_content "土日・祝日勤務時間 8時間 0分"
        expect(page).to have_content "特別日勤務時間 8時間 0分"
        expect(page).to have_content "合計勤務時間 24時間 0分"
      end

      it "合計残業時間が表示される" do
        expect(page).to have_content "残業時間"
        expect(page).to have_content "平日残業時間 1時間 0分"
        expect(page).to have_content "土日・祝日残業時間 1時間 0分"
        expect(page).to have_content "特別日残業時間 1時間 0分"
        expect(page).to have_content "合計残業時間 3時間 0分"
      end

      it "合計基本給が表示される" do
        expect(page).to have_content "基本給"
        expect(page).to have_content "平日基本給 8,000円"
        expect(page).to have_content "土日・祝日基本給 8,800円"
        expect(page).to have_content "特別日基本給 8,800円"
        expect(page).to have_content "合計基本給 25,600円"
      end

      it "合計残業代が表示される" do
        expect(page).to have_content "残業代"
        expect(page).to have_content "平日残業代 1,000円"
        expect(page).to have_content "土日・祝日残業代 1,100円"
        expect(page).to have_content "特別日残業代 1,100円"
        expect(page).to have_content "合計残業代 3,200円"
      end

      it "合計特別日手当が表示される" do
        expect(page).to have_content "合計特別日手当 3,000円"
      end

      it "合計交通費が表示される" do
        expect(page).to have_content "合計交通費 1,920円"
      end

      it "総支給額が表示される" do
        expect(page).to have_content "総支給額 33,720円"
      end
    end
  end

  describe "勤怠詳細ページ表示" do
    context "ログインしている場合" do
      before do
        sign_in user
        visit date_attendances_path(Time.current)
      end

      context "日付が今日の場合" do
        context "既に勤怠記録がある場合" do
          let!(:attendance) { create(:attendance, user:, date: Date.current, clock_in_time: "10:00", clock_out_time: "14:00") }

          it "既存の勤怠記録を表示し、データベースに存在することを確認する" do
            expect(page).to have_button "出勤", disabled: true
            expect(page).to have_button "退勤", disabled: true
            expect(page).to have_content attendance.clock_in_time.strftime("%H:%M")
            expect(page).to have_content attendance.clock_out_time.strftime("%H:%M")

            expect(Attendance).to exist(user:, date: Date.current)
          end
        end

        context "勤怠記録がない場合" do
          it "新しい勤怠記録をインスタンス化し、データベースに存在しないことを確認する" do
            expect(page).to have_button "出勤"
            expect(page).to have_button "退勤", disabled: true
            expect(page).not_to have_content attendance.clock_in_time.strftime("%H:%M")
            expect(page).not_to have_content attendance.clock_out_time.strftime("%H:%M")

            expect(Attendance).not_to exist(user:, date: Date.current)
          end
        end

        context "特別日の場合" do
          let!(:special_day) { create(:special_day, start_date: Date.current, end_date: Date.current) }
          let!(:attendance) { create(:attendance, user:, date: Date.current, special_day: true) }

          it "日付の下に特別日と表示される" do
            expect(page).to have_content "（特別日）"
          end
        end
      end

      context "日付が今日ではない場合" do
        before do
          sign_in user
          visit date_attendances_path(attendance.date)
        end

        context "既に勤怠記録がある場合" do
          it "既存の勤怠記録を表示し、データベースに存在することを確認する" do
            expect(page).not_to have_button "出勤"
            expect(page).not_to have_button "退勤"
            expect(page).to have_content attendance.clock_in_time.strftime("%H:%M")
            expect(page).to have_content attendance.clock_out_time.strftime("%H:%M")

            expect(Attendance).to exist(user:)
          end
        end

        context "勤怠記録がない場合" do
          let!(:attendance) { build(:attendance, user:) }

          it "新しい勤怠記録をインスタンス化し、データベースに存在しないことを確認する" do
            expect(page).not_to have_button "出勤"
            expect(page).not_to have_button "退勤"
            expect(page).not_to have_content attendance.clock_in_time.strftime("%H:%M")
            expect(page).not_to have_content attendance.clock_out_time.strftime("%H:%M")

            expect(Attendance).not_to exist(user:)
          end
        end
      end
    end

    context "未ログインの場合" do
      it "ログイン画面にリダイレクトされる" do
        visit date_attendances_path(attendance.date)

        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "出勤" do
    let!(:attendance) { create(:attendance, date: Time.current, clock_in_time: nil, clock_out_time: nil, user:) }

    before do
      sign_in user
      visit date_attendances_path(attendance.date)
    end

    context "まだ出勤していない場合" do
      it "出勤が成功する" do
        expect(page).to have_button "出勤"

        click_button "出勤"

        expect(page).to have_content("出勤しました")
        expect(page).to have_button "出勤", disabled: true
        expect(page).to have_button "退勤"
      end
    end

    context "既に出勤している場合" do
      let!(:attendance) { create(:attendance, date: Time.current, clock_out_time: nil, user:) }

      it "出勤ボタンがdisabledであり、出勤時刻が表示されている" do
        expect(page).to have_button "出勤", disabled: true
        expect(page).to have_button "退勤"
        expect(page).to have_content "10:00"
      end
    end
  end

  describe "退勤" do
    let!(:attendance) { create(:attendance, date: Time.current, clock_in_time: nil, clock_out_time: nil, user:) }

    before do
      sign_in user
      visit date_attendances_path(attendance.date)
    end

    context "まだ出勤も退勤もしていない場合" do
      it "出勤ボタンがクリックできて、退勤ボタンがdisabledである" do
        expect(page).to have_button "出勤"
        expect(page).to have_button "退勤", disabled: true
      end
    end

    context "出勤していてまだ退勤していない場合" do
      let!(:attendance) { create(:attendance, date: Time.current, clock_out_time: nil, user:) }

      it "退勤が成功する" do
        expect(page).to have_button "出勤", disabled: true
        expect(page).to have_button "退勤"
        expect(page).to have_content "10:00"

        click_button "退勤"

        expect(page).to have_content "退勤しました"
        expect(page).to have_button "退勤", disabled: true
      end
    end

    context "出勤して既に退勤している場合" do
      let!(:attendance) { create(:attendance, date: Time.current, user:) }

      it "出勤・退勤ボタンの両方がdisabledである" do
        expect(page).to have_button "出勤", disabled: true
        expect(page).to have_button "退勤", disabled: true
        expect(page).to have_content "14:00"
      end
    end
  end
end
