require "rails_helper"

RSpec.describe "SpecialDays", type: :system do
  before do
    driven_by(:rack_test)
  end

  let!(:admin) { create(:admin) }
  let!(:user) { create(:user) }

  describe "特別日作成" do
    context "管理ユーザーでログイン済みの場合" do
      before do
        sign_in admin
        visit new_admins_special_day_path
      end

      it "特別日作成画面にアクセスが成功する" do
        expect(page).to have_title("特別日作成")
      end

      it "フォームを正しく入力すると特別日がデータベースに保存され、特別日一覧にリダイレクトする" do
        fill_in "開始日", with: Date.new(2024, 4, 29)
        fill_in "終了日", with: Date.new(2024, 5, 5)
        fill_in "説明", with: "GW"
        fill_in "時給加算額", with: 100
        fill_in "手当", with: 1500

        expect {
          click_button "保存"
        }.to change { SpecialDay.count }.by(1)

        expect(page).to have_content("特別日が作成されました")
        expect(page).to have_current_path(admins_special_days_path)
      end

      it "入力が正しくないと、エラーメッセージが表示される" do
        fill_in "終了日", with: Date.new(2024, 5, 5)
        fill_in "説明", with: "GW"
        fill_in "時給加算額", with: 100
        fill_in "手当", with: 1500
        click_button "保存"

        expect(page).to have_content("開始日を入力してください")
      end
    end

    context "管理ユーザーで未ログインの場合" do
      it "特別日作成画面へのアクセスが失敗し、管理ログイン画面にリダイレクトされる" do
        visit new_admins_special_day_path

        expect(page).to have_current_path(new_admin_session_path)
      end
    end

    context "一般ユーザーが特別日作成画面にアクセスした場合" do
      before do
        sign_in user
      end

      it "アクセスが失敗し、管理ログイン画面にリダイレクトされる" do
        visit new_admins_special_day_path

        expect(page).to have_current_path(new_admin_session_path)
      end
    end
  end

  describe "特別日一覧" do
    context "管理ユーザーでログイン済みの場合" do
      let!(:special_days) { create_list(:special_day, 100) }

      before do
        sign_in admin
        visit admins_special_days_path
      end

      it "特別日一覧画面にアクセスが成功する" do
        expect(page).to have_title("特別日一覧")
      end

      it "作成日が新しい順で特別日が表示される" do
        expect(page).to have_content("100 件中 0 〜 10 件")
      end

      it "2ページ目への移動が成功する" do
        click_link "2"
        expect(page).to have_current_path(admins_special_days_path(page: 2))
        expect(page).to have_content("100 件中 10 〜 20 件")
      end

      it "次のページへの移動が成功する" do
        visit admins_special_days_path
        click_link "›"
        expect(page).to have_current_path(admins_special_days_path(page: 2))
        expect(page).to have_content("100 件中 10 〜 20 件")
      end

      it "最後のページへの移動が成功する" do
        visit admins_special_days_path
        click_link "»"
        expect(page).to have_current_path(admins_special_days_path(page: 10))
        expect(page).to have_content("100 件中 90 〜 100 件")
      end

      it "前のページへの移動が成功する" do
        visit admins_special_days_path(page: 2)
        click_link "‹"
        expect(page).to have_current_path(admins_special_days_path)
        expect(page).to have_content("100 件中 0 〜 10 件")
      end

      it "最初のページへの移動が成功する" do
        visit admins_special_days_path(page: 10)
        click_link "«"
        expect(page).to have_current_path(admins_special_days_path)
        expect(page).to have_content("100 件中 0 〜 10 件")
      end
    end

    context "管理ユーザーで未ログインの場合" do
      it "特別日一覧画面へのアクセスが失敗し、管理ログイン画面にリダイレクトされる" do
        visit admins_special_days_path

        expect(page).to have_current_path(new_admin_session_path)
      end
    end

    context "一般ユーザーが特別日一覧画面にアクセスした場合" do
      before do
        sign_in user
      end

      it "アクセスが失敗し、管理ログイン画面にリダイレクトされる" do
        visit admins_special_days_path

        expect(page).to have_current_path(new_admin_session_path)
      end
    end
  end
end
