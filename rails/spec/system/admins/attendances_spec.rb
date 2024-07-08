require "rails_helper"

RSpec.describe "Admins::Attendances", type: :system do
  before do
    driven_by(:rack_test)
  end

  def create_users_with_attendances(count = 100)
    count.times do |n|
      user = create(:user)
      create(:attendance, user:)
    end
  end

  describe '管理勤怠一覧' do
    let!(:admin) { create(:admin, name: "admin", password: "password") }

    context '管理者がログイン済みの場合' do
      before do
        create_users_with_attendances(100)

        sign_in admin
        visit admins_attendances_path
      end

      it '管理勤怠一覧画面にアクセスが成功する' do
        expect(page).to have_content "管理勤怠一覧"
        expect(page).to have_content "admin"
        expect(page).to have_content "ログアウト"
        expect(page).to have_content "No"
        expect(page).to have_content "名前"
        expect(page).to have_content "日付"
        expect(page).to have_content "出勤時刻"
        expect(page).to have_content "退勤時刻"
        expect(page).to have_content "100"
        expect(page).to have_selector ".pagination"
      end

      it "2ページ目への移動が成功する" do
        visit admins_attendances_path
        click_link "2"
        expect(page).to have_current_path(admins_attendances_path(page: 2))
      end

      it "次のページへの移動が成功する" do
        visit admins_attendances_path
        click_link "›"
        expect(page).to have_current_path(admins_attendances_path(page: 2))
      end

      it "最後のページへの移動が成功する" do
        visit admins_attendances_path
        click_link "»"
        expect(page).to have_current_path(admins_attendances_path(page: 10))
      end

      it "前のページへの移動が成功する" do
        visit admins_attendances_path(page: 2)
        click_link "‹"
        expect(page).to have_current_path(admins_attendances_path)
      end

      it "最初のページへの移動が成功する" do
        visit admins_attendances_path(page: 10)
        click_link "«"
        expect(page).to have_current_path(admins_attendances_path)
      end
    end

    context '管理者が未ログインの場合' do
      it '管理勤怠一覧画面にアクセスすると管理ログイン画面にリダイレクトされる' do
        visit admins_attendances_path
        expect(page).to have_current_path(new_admin_session_path)
      end
    end

    context '一般ユーザーがログイン済みの場合' do
      let!(:user) { create(:user) }

      before do
        sign_in user
      end

      it '一般ユーザーが管理勤怠一覧画面にアクセスすると管理ログイン画面にリダイレクトされる' do
        visit admins_attendances_path
        expect(page).to have_current_path(new_admin_session_path)
      end
    end

  end

end
