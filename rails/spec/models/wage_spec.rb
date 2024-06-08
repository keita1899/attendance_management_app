require "rails_helper"

RSpec.describe Wage, type: :model do
  describe "バリデーション" do
    let!(:user) { build(:user) }
    let!(:wage) { FactoryBot.build(:wage, user:) }

    context "成功する場合" do
      it "正しく入力されている時" do
        expect(wage).to be_valid
      end
    end

    context "失敗する場合" do
      it "平日時給が空だと保存できない" do
        wage.weekday_hourly_wage = nil
        expect(wage).not_to be_valid
        expect(wage.errors[:weekday_hourly_wage]).to include("を入力してください")
      end

      it "土日・祝日時給が空だと保存できない" do
        wage.weekend_hourly_wage = nil
        expect(wage).not_to be_valid
        expect(wage.errors[:weekend_hourly_wage]).to include("を入力してください")
      end

      it "平日時給が文字列だと保存できない" do
        wage.weekday_hourly_wage = "test"
        expect(wage).not_to be_valid
        expect(wage.errors[:weekday_hourly_wage]).to include("は数値で入力してください")
      end

      it "土日・祝日時給が文字列だと保存できない" do
        wage.weekend_hourly_wage = "test"
        expect(wage).not_to be_valid
        expect(wage.errors[:weekend_hourly_wage]).to include("は数値で入力してください")
      end

      it "平日時給が0より小さいと保存できない" do
        wage.weekday_hourly_wage = -1
        expect(wage).not_to be_valid
        expect(wage.errors[:weekday_hourly_wage]).to include("は0以上の値にしてください")
      end

      it "土日・祝日時給が0より小さいと保存できない" do
        wage.weekend_hourly_wage = -1
        expect(wage).not_to be_valid
        expect(wage.errors[:weekend_hourly_wage]).to include("は0以上の値にしてください")
      end
    end
  end
end
