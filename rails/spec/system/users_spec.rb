require "rails_helper"

RSpec.describe "Users", type: :system do
  before do
    driven_by(:rack_test)
  end

  def fill_in_registration_form(user_info)
    fill_in "姓", with: user_info[:last_name]
    fill_in "名", with: user_info[:first_name]
    fill_in "セイ", with: user_info[:last_name_kana]
    fill_in "メイ", with: user_info[:first_name_kana]
    fill_in "メールアドレス", with: user_info[:email]
    fill_in "パスワード", with: user_info[:password]
    fill_in "パスワード（確認用）", with: user_info[:password_confirmation]
  end

  def fill_in_login_form(user_info)
    fill_in "メールアドレス", with: user_info[:email]
    fill_in "パスワード", with: user_info[:password]
  end

  describe "ユーザー登録" do
    let(:valid_user_info) do
      {
        last_name: "山田",
        first_name: "太郎",
        last_name_kana: "ヤマダ",
        first_name_kana: "タロウ",
        email: "test@example.com",
        password: "password",
        password_confirmation: "password",
      }
    end

    let(:invalid_user_info) do
      {
        last_name: "山田",
        first_name: "太郎",
        last_name_kana: "ヤマダ",
        first_name_kana: "タロウ",
        email: "",
        password: "password",
        password_confirmation: "password",
      }
    end

    it "ユーザー登録が成功する" do
      visit new_user_registration_path
      fill_in_registration_form(valid_user_info)
      click_button "登録"

      expect(page).to have_content("アカウント登録が完了しました")
      expect(User.find_by(email: "test@example.com")).not_to be_nil
    end

    it "ユーザー登録が失敗する" do
      visit new_user_registration_path
      fill_in_registration_form(invalid_user_info)
      click_button "登録"

      expect(page).to have_content("アカウント登録に失敗しました")
      expect(User.find_by(email: "test@example.com")).to be_nil
    end
  end

  describe "ログイン" do
    before do
      FactoryBot.create(:user, email: "test@example.com", password: "password")
    end

    let(:valid_login_info) { { email: "test@example.com", password: "password" } }
    let(:invalid_email_info) { { email: "different@example.com", password: "password" } }
    let(:invalid_password_info) { { email: "test@example.com", password: "different" } }

    it "ログインが成功する" do
      visit new_user_session_path
      fill_in_login_form(valid_login_info)
      click_button "ログイン"
      expect(page).to have_content("ログインしました")
      expect(User.find_by(email: "test@example.com")).not_to be_nil
    end

    it "間違ったメールアドレスでログインが失敗する" do
      visit new_user_session_path
      fill_in_login_form(invalid_email_info)
      click_button "ログイン"

      expect(page).to have_content("メールアドレスかパスワードが間違っています")
    end

    it "間違ったパスワードでログインが失敗する" do
      visit new_user_session_path
      fill_in_login_form(invalid_password_info)
      click_button "ログイン"

      expect(page).to have_content("メールアドレスかパスワードが間違っています")
    end
  end

  describe "ログアウト" do
    let!(:user) { FactoryBot.create(:user, email: "test@example.com", password: "password") }
    let(:valid_login_info) { { email: "test@example.com", password: "password" } }

    before do
      visit new_user_session_path
      fill_in_login_form(valid_login_info)
      click_button "ログイン"
    end

    it "ログアウトが成功する" do
      click_link "ログアウト"
      expect(page).to have_content("ログアウトしました")
      expect(page).to have_current_path(root_path)
      expect(page).to have_link("ログイン")
      expect(page).to have_link("ユーザー登録")
      expect(page).not_to have_link("ログアウト")
    end
  end
end