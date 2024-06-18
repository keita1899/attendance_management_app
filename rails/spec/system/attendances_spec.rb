require "rails_helper"

RSpec.describe "Attendances", type: :system do
  before do
    driven_by(:rack_test)
  end

  let!(:user) { create(:user) }
  let!(:attendance) { create(:attendance, user:) }

  describe "カレンダーページ表示" do
    context "未ログインの場合" do
      it "ログイン画面にリダイレクトされる" do
        visit attendances_path

        expect(page).to have_current_path(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      it "カレンダーページが表示される" do
        sign_in user

        visit attendances_path
        expect(page).to have_title("カレンダー")
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
            expect(page).to have_content(attendance.clock_in_time.strftime("%H:%M"))
            expect(page).to have_content(attendance.clock_out_time.strftime("%H:%M"))

            expect(Attendance).to exist(user:, date: Date.current)
          end
        end

        context "勤怠記録がない場合" do
          it "新しい勤怠記録をインスタンス化し、データベースに存在しないことを確認する" do
            expect(page).to have_button "出勤"
            expect(page).to have_button "退勤", disabled: true
            expect(page).not_to have_content(attendance.clock_in_time.strftime("%H:%M"))
            expect(page).not_to have_content(attendance.clock_out_time.strftime("%H:%M"))

            expect(Attendance).not_to exist(user:, date: Date.current)
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
            expect(page).to have_content(attendance.clock_in_time.strftime("%H:%M"))
            expect(page).to have_content(attendance.clock_out_time.strftime("%H:%M"))

            expect(Attendance).to exist(user:)
          end
        end

        context "勤怠記録がない場合" do
          let!(:attendance) { build(:attendance, user:) }

          it "新しい勤怠記録をインスタンス化し、データベースに存在しないことを確認する" do
            expect(page).not_to have_button "出勤"
            expect(page).not_to have_button "退勤"
            expect(page).not_to have_content(attendance.clock_in_time.strftime("%H:%M"))
            expect(page).not_to have_content(attendance.clock_out_time.strftime("%H:%M"))

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

        expect(page).to have_content("退勤しました")
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
