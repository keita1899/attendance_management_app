require "rails_helper"

RSpec.describe "Users", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "ユーザー登録が成功する" do
    visit new_user_registration_path
    fill_in "姓", with: "山田"
    fill_in "名", with: "太郎"
    fill_in "セイ", with: "ヤマダ"
    fill_in "メイ", with: "タロウ"
    fill_in "メールアドレス", with: "test@example.com"
    fill_in "パスワード", with: "password"
    fill_in "パスワード（確認用）", with: "password"
    click_button "登録"

    expect(page).to have_content("アカウント登録が完了しました")
    expect(User.find_by(email: "test@example.com")).not_to be_nil
  end

  it "ユーザー登録が失敗する" do
    visit new_user_registration_path
    fill_in "姓", with: "山田"
    fill_in "名", with: "太郎"
    fill_in "セイ", with: "ヤマダ"
    fill_in "メイ", with: "タロウ"
    fill_in "メールアドレス", with: ""
    fill_in "パスワード", with: "password"
    fill_in "パスワード（確認用）", with: "password"
    click_button "登録"

    expect(page).to have_content("アカウント登録に失敗しました")
    expect(User.find_by(email: "test@example.com")).to be_nil
  end
end
