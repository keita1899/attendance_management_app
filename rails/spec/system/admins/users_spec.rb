require "rails_helper"

RSpec.describe "Admins::Users", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "管理画面ユーザー一覧" do
    let!(:admin) { create(:admin, name: "admin", password: "password") }

    context "ログイン済みの場合" do
      let!(:users) { create_list(:user, 100) }

      before do
        sign_in admin
      end

      it "管理画面のユーザー一覧にアクセスが成功する" do
        visit admins_users_path
        expect(page).to have_content("ユーザー")
        expect(page).to have_content("100")
        expect(page).to have_selector(".pagination")
      end

      it "2ページ目への移動が成功する" do
        visit admins_users_path
        click_link "2"
        expect(page).to have_current_path(admins_users_path(page: 2))
      end

      it "次のページへの移動が成功する" do
        visit admins_users_path
        click_link "›"
        expect(page).to have_current_path(admins_users_path(page: 2))
      end

      it "最後のページへの移動が成功する" do
        visit admins_users_path
        click_link "»"
        expect(page).to have_current_path(admins_users_path(page: 10))
      end

      it "前のページへの移動が成功する" do
        visit admins_users_path(page: 2)
        click_link "‹"
        expect(page).to have_current_path(admins_users_path)
      end

      it "最初のページへの移動が成功する" do
        visit admins_users_path(page: 10)
        click_link "«"
        expect(page).to have_current_path(admins_users_path)
      end
    end

    context "未ログインの場合" do
      it "管理画面のユーザー一覧にアクセスすると管理ログイン画面にリダイレクトされる" do
        visit admins_users_path
        expect(page).to have_current_path(new_admin_session_path)
      end
    end

    context "一般ユーザーがアクセスする場合" do
      let!(:user) { create(:user) }

      before do
        sign_in user
      end

      it "管理画面ユーザー一覧にアクセスすると管理ログイン画面にリダイレクトされる" do
        visit admins_users_path
        expect(page).to have_current_path(new_admin_session_path)
      end
    end
  end

  describe "管理画面ユーザー編集" do
    let!(:admin) { create(:admin, name: "admin", password: "password") }

    context "ログイン済みの場合" do
      let!(:user) { create(:user) }

      before do
        sign_in admin
      end

      it "管理画面ユーザー編集画面にアクセスが成功する" do
        visit edit_admins_user_path(user)
        expect(page).to have_content("平日時給")
        expect(page).to have_content("土日・祝日時給")
        expect(page).to have_field("wage_weekday_rate", with: 1000)
        expect(page).to have_field("wage_weekend_rate", with: 1100)
      end

      it "ユーザー情報の更新が成功する" do
        visit edit_admins_user_path(user)
        fill_in "平日時給", with: 1200
        fill_in "土日・祝日時給", with: 1300
        click_button "保存"
        expect(page).to have_current_path(admins_users_path)
      end
    end

    context "未ログインの場合" do
      it "管理画面のユーザー編集画面にアクセスすると管理ログイン画面にリダイレクトされる" do
        visit edit_admins_user_path(1)
        expect(page).to have_current_path(new_admin_session_path)
      end
    end

    context "一般ユーザーがアクセスする場合" do
      let!(:user) { create(:user) }

      before do
        sign_in user
      end

      it "管理画面ユーザー編集画面にアクセスすると管理ログイン画面にリダイレクトされる" do
        visit edit_admins_user_path(1)
        expect(page).to have_current_path(new_admin_session_path)
      end
    end
  end

  describe "ユーザー削除" do
    let!(:admin) { create(:admin, name: "admin", password: "password") }
    let!(:users) { create_list(:user, 100) }

    before do
      sign_in admin
    end

    it "削除ボタンをクリックして確認ダイアログで削除をクリックするとユーザーの削除が成功する", js: true do
      visit edit_admins_user_path(users.first)
      expect(page).to have_content("削除")

      expect {
        click_link "削除"
      }.to change { User.count }.by(-1)

      expect(page).to have_current_path(admins_users_path, ignore_query: true)
      expect(page).to have_content("ユーザーを削除しました")
    end
  end
end
