require "rails_helper"

RSpec.describe "Admins", type: :system do
  before do
    driven_by(:rack_test)
  end

  def fill_in_login_form(admin_info)
    fill_in "ユーザー名", with: admin_info[:name]
    fill_in "パスワード", with: admin_info[:password]
  end

  describe "管理ユーザーログイン" do
    before do
      create(:admin, name: "admin", password: "password")
    end

    let(:valid_admin_info) do
      {
        name: "admin",
        password: "password",
      }
    end

    let(:invalid_name_info) do
      {
        name: "test",
        password: "password",
      }
    end

    let(:invalid_password_info) do
      {
        name: "admin",
        password: "different",
      }
    end

    context "未ログインの場合" do
      it "管理ユーザーログインが成功する" do
        visit new_admin_session_path
        fill_in_login_form(valid_admin_info)
        click_button "ログイン"

        expect(Admin.find_by(name: "admin")).not_to be_nil
        expect(page).to have_current_path(admins_root_path)
        expect(page).to have_content("ログインしました")
        expect(page).to have_link("ログアウト")
      end

      it "間違ったユーザー名でログインが失敗する" do
        visit new_admin_session_path
        fill_in_login_form(invalid_name_info)
        click_button "ログイン"

        expect(page).to have_content("ユーザー名かパスワードが間違っています")
      end

      it "間違ったパスワードでログインが失敗する" do
        visit new_admin_session_path
        fill_in_login_form(invalid_password_info)
        click_button "ログイン"

        expect(page).to have_content("ユーザー名かパスワードが間違っています")
      end
    end

    context "ログイン済みの場合" do
      before do
        visit new_admin_session_path
        fill_in_login_form(valid_admin_info)
        click_button "ログイン"
      end

      it "管理ユーザーログインページに遷移しようとすると管理ダッシュボードにリダイレクトされる" do
        visit new_admin_session_path

        expect(page).to have_current_path(admins_root_path)
        expect(page).to have_content("すでにログイン済みです")
      end
    end
  end

  describe "管理ユーザーログアウト" do
    let!(:admin) { create(:admin, name: "admin", password: "password") }
    let!(:valid_login_info) { { name: "admin", password: "password" } }

    before do
      visit new_admin_session_path
      fill_in_login_form(valid_login_info)
      click_button "ログイン"
    end

    it "ログアウトが成功する" do
      click_link "ログアウト"
      expect(page).to have_content("ログアウトしました")
      expect(page).to have_current_path(new_admin_session_path)
      expect(page).to have_link("ログイン")
      expect(page).to have_link("アカウント登録")
      expect(page).not_to have_link("ログアウト")
    end
  end
end
