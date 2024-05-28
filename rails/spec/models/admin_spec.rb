require "rails_helper"

RSpec.describe Admin, type: :model do
  describe "管理ユーザーログイン" do
    let(:admin) { FactoryBot.create(:admin) }

    context "ログインが成功する時" do
      it "正しいユーザー名とパスワードが入力されている時" do
        expect(admin.valid_password?("password")).to be true
      end
    end

    context "失敗する時" do
      it "ユーザー名が空だとログインできない" do
        admin.name = nil
        expect(admin).not_to be_valid
        expect(admin.errors[:name]).to include("を入力してください")
      end

      it "パスワードが空だとログインできない" do
        admin.password = nil
        expect(admin).not_to be_valid
        expect(admin.errors[:password]).to include("を入力してください")
      end

      it "ユーザー名が異なるとログインできない" do
        invalid_admin = Admin.find_by(name: "user")
        expect(invalid_admin).to be_nil
      end

      it "パスワードが異なるとログインできない" do
        expect(admin.valid_password?("different")).to be false
      end
    end
  end
end
