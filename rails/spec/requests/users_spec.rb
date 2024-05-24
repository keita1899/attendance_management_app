require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "GET /users/sign_up" do
    it "ユーザー登録画面にアクセス成功する" do
      get new_user_registration_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users" do
    it "ユーザー登録画面でフォームを送信してユーザーのデータを登録する" do
      expect {
        post user_registration_path, params: { user: {
          last_name: "山田",
          first_name: "太郎",
          last_name_kana: "ヤマダ",
          first_name_kana: "タロウ",
          email: "test@example.com",
          password: "password",
          password_confirmation: "password",
        } }
      }.to change { User.count }.by(1)
      expect(response).to have_http_status(:see_other)
    end
  end
end
