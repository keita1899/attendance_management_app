require "rails_helper"

RSpec.describe "Admins::Dashboard", type: :system do
  before do
    driven_by(:rack_test)
  end

  let!(:admin) { create(:admin) }
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:attendance1) { create(:attendance, user: user1, date: Date.current, clock_in_time: Time.current.change(hour: 9, min: 0), clock_out_time: nil) }
  let!(:attendance2) {
    create(:attendance, user: user2, date: Date.current, clock_in_time: Time.current.change(hour: 10, min: 0),
                        clock_out_time: Time.current.change(hour: 14, min: 0))
  }
  let!(:old_attendance) {
    create(:attendance, user: user1, date: Date.current - 1.day, clock_in_time: Time.current.change(hour: 10, min: 0),
                        clock_out_time: Time.current.change(hour: 14, min: 0))
  }

  describe "ダッシュボード" do
    context "管理者がログイン済の場合" do
      before do
        sign_in admin
        visit admins_root_path
      end

      it "今日の日付が表示される" do
        formatted_date = I18n.l(Date.current, format: :long)
        expect(page).to have_content("本日 #{formatted_date} の出勤")
      end

      it "本日の出勤リストが表示される" do
        expect(page).to have_content user1.full_name
        expect(page).to have_content user2.full_name
      end

      it "出勤中のユーザーが表示される" do
        expect(page).to have_content user1.full_name
        expect(page).to have_css(".badge.bg-success", text: "出勤中", count: 1)
      end

      it "退勤済のユーザーが表示される" do
        expect(page).to have_content user2.full_name
        expect(page).to have_css(".badge.bg-dark", text: "退勤済", count: 1)
      end

      it "出勤者がいない場合はメッセージが表示される" do
        Attendance.delete_all
        visit admins_root_path
        expect(page).to have_content "0 人"
        expect(page).to have_content "本日は出勤者がいません"
      end
    end

    context "管理者が未ログインの場合" do
      it "管理ログイン画面にリダイレクトされる" do
        visit admins_root_path
        expect(page).to have_current_path new_admin_session_path
      end
    end

    context "一般ユーザーがアクセスした場合" do
      let!(:user) { create(:user) }

      before do
        sign_in user
      end

      it "管理ログイン画面にリダイレクトされる" do
        visit admins_root_path
        expect(page).to have_current_path new_admin_session_path
      end
    end
  end
end
