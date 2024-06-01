require "rails_helper"

RSpec.describe User, type: :model do
  describe "フルネームを取得" do
    let(:user) { build(:user) }

    it "フルネームを取得できる" do
      expect(user.full_name).to eq("山田太郎")
    end
  end

  describe "ユーザー登録" do
    let(:user) { build(:user) }

    context "新規登録が成功する時" do
      it "全ての項目が正しく入力されている時" do
        expect(user).to be_valid
      end
    end

    context "新規登録が失敗する時" do
      it "姓が空だと登録できない" do
        user.last_name = nil
        expect(user).not_to be_valid
        expect(user.errors[:last_name]).to include("を入力してください")
      end

      it "名が空だと登録できない" do
        user.first_name = nil
        expect(user).not_to be_valid
        expect(user.errors[:first_name]).to include("を入力してください")
      end

      it "が空だと登録できない" do
        user.last_name_kana = nil
        expect(user).not_to be_valid
        expect(user.errors[:last_name_kana]).to include("を入力してください")
      end

      it "メイが空だと登録できない" do
        user.first_name_kana = nil
        expect(user).not_to be_valid
        expect(user.errors[:first_name_kana]).to include("を入力してください")
      end

      it "メールアドレスが空だと登録できない" do
        user.email = nil
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("を入力してください")
      end

      it "パスワードが空だと登録できない" do
        user.password = nil
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("を入力してください")
      end

      it "パスワード確認用が空だと登録できない" do
        user.password_confirmation = nil
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to include("を入力してください")
      end

      it "姓が全角ではないと登録できない" do
        user.last_name = "yamada"
        expect(user).not_to be_valid
        expect(user.errors[:last_name]).to include("は全角で入力してください")
      end

      it "名が全角ではないと登録できない" do
        user.first_name = "taro"
        expect(user).not_to be_valid
        expect(user.errors[:first_name]).to include("は全角で入力してください")
      end

      it "セイがカタカナではないと登録できない" do
        user.last_name_kana = "やまだ"
        expect(user).not_to be_valid
        expect(user.errors[:last_name_kana]).to include("はカタカナで入力してください")
      end

      it "メイがカタカナではないと登録できない" do
        user.first_name_kana = "たろう"
        expect(user).not_to be_valid
        expect(user.errors[:first_name_kana]).to include("はカタカナで入力してください")
      end

      it "メールアドレスがすでに登録されていると登録できない" do
        create(:user, email: "test1@example.com")
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("はすでに存在します")
      end

      it "メールアドレスの形式が間違っていると登録できない" do
        user.email = "test"
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("は不正な値です")
      end

      it "メールアドレスに@が含まれていない場合は登録できない" do
        user.email = "test@"
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("は不正な値です")
      end

      it "メールアドレスのドメインが指定されていない場合は登録できない" do
        user.email = "@example"
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("は不正な値です")
      end

      it "メールアドレスのドメインが不完全な場合は登録できない" do
        user.email = "@example.com"
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("は不正な値です")
      end

      it "メールアドレスが@を含まずドメインも指定されていない場合は登録できない" do
        user.email = "@com"
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("は不正な値です")
      end

      it "パスワードの文字数が8文字より少ないと登録できない" do
        user.password = "passwor"
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("は8文字以上で入力してください")
      end

      it "パスワードの文字数が129文字以上だと登録できない" do
        user.password = "a" * 129
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("は128文字以内で入力してください")
      end

      it "パスワードとパスワード（確認用）が異なると登録できない" do
        user.password = "password"
        user.password_confirmation = "different"
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to include("とパスワードの入力が一致しません")
      end
    end
  end

  describe "ログイン" do
    let(:user) { create(:user) }

    context "ログインが成功する時" do
      it "正しいメールアドレスとパスワードが入力されている時" do
        expect(user.valid_password?("password")).to be true
      end
    end

    context "ログインが失敗する時" do
      it "メールアドレスが空だとログインできない" do
        user.email = nil
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("を入力してください")
      end

      it "パスワードが空だとログインできない" do
        user.password = nil
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("を入力してください")
      end

      it "メールアドレスが異なるとログインできない" do
        invalid_user = User.find_by(email: "invalid@example.com")
        expect(invalid_user).to be_nil
      end

      it "パスワードが異なるとログインできない" do
        expect(user.valid_password?("different")).to be false
      end
    end
  end
end
