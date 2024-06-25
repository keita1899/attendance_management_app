require "rails_helper"

RSpec.describe SpecialDay, type: :model do
  describe "バリデーション" do
    let(:special_day) { build(:special_day) }

    it "全ての項目が正しく入力されている場合登録できる" do
      expect(special_day).to be_valid
    end

    it "開始日が空だと登録できない" do
      special_day.start_date = nil
      expect(special_day).not_to be_valid
      expect(special_day.errors[:start_date]).to include("を入力してください")
    end

    it "終了日が空だと登録できない" do
      special_day.end_date = nil
      expect(special_day).not_to be_valid
      expect(special_day.errors[:end_date]).to include("を入力してください")
    end

    it "説明が空だと登録できない" do
      special_day.description = nil
      expect(special_day).not_to be_valid
      expect(special_day.errors[:description]).to include("を入力してください")
    end

    it "時給加算額が空だと登録できない" do
      special_day.wage_increment = nil
      expect(special_day).not_to be_valid
      expect(special_day.errors[:wage_increment]).to include("を入力してください")
    end

    it "手当が空だと登録できない" do
      special_day.allowance = nil
      expect(special_day).not_to be_valid
      expect(special_day.errors[:allowance]).to include("を入力してください")
    end

    it "開始日が終了日より後の日付だと登録できない" do
      special_day.start_date = Time.zone.local(2024, 8, 20)
      special_day.end_date = Time.zone.local(2024, 8, 17)
      expect(special_day).not_to be_valid
      expect(special_day.errors[:start_date]).to include("は終了日より前でなければなりません")
    end

    it "終了日が開始日より前の日付だと登録できない" do
      special_day.start_date = Time.zone.local(2024, 8, 17)
      special_day.end_date = Time.zone.local(2024, 8, 12)
      expect(special_day).not_to be_valid
      expect(special_day.errors[:end_date]).to include("は開始日より後でなければなりません")
    end

    it "開始日と終了日が同じ日付だと登録できる" do
      special_day.start_date = special_day.end_date
      expect(special_day).to be_valid
    end

    it "説明が31文字以上だと登録できない" do
      special_day.description = "a" * 31
      expect(special_day).not_to be_valid
      expect(special_day.errors[:description]).to include("は30文字以内で入力してください")
    end

    it "説明が30文字だと登録できる" do
      special_day.description = "a" * 30
      expect(special_day).to be_valid
    end

    it "時給加算額が数値ではないと登録できない" do
      special_day.wage_increment = "string"
      expect(special_day).not_to be_valid
      expect(special_day.errors[:wage_increment]).to include("は数値で入力してください")
    end

    it "手当が数値ではないと登録できない" do
      special_day.allowance = "string"
      expect(special_day).not_to be_valid
      expect(special_day.errors[:allowance]).to include("は数値で入力してください")
    end

    it "時給加算額が0だと登録できる" do
      special_day.wage_increment = 0
      expect(special_day).to be_valid
    end

    it "手当が0だと登録できる" do
      special_day.allowance = 0
      expect(special_day).to be_valid
    end

    it "時給加算額が0より小さい数値だと登録できない" do
      special_day.wage_increment = -1
      expect(special_day).not_to be_valid
      expect(special_day.errors[:wage_increment]).to include("は0以上の値にしてください")
    end

    it "手当が0より小さい数値だと登録できない" do
      special_day.allowance = -1
      expect(special_day).not_to be_valid
      expect(special_day.errors[:allowance]).to include("は0以上の値にしてください")
    end

    describe "日付の重複チェック" do
      let!(:existing_special_day) { create(:special_day, start_date: Time.zone.local(2024, 8, 13), end_date: Time.zone.local(2024, 8, 17)) }

      context "開始日が重複している時" do
        let!(:special_day) { build(:special_day, start_date: Time.zone.local(2024, 8, 17), end_date: Time.zone.local(2024, 8, 20)) }

        it "登録できない" do
          expect(special_day).not_to be_valid
          expect(special_day.errors[:base]).to include("既存の特別日と日付が重複しています")
        end
      end

      context "終了日が重複している場合" do
        let!(:special_day) { build(:special_day, start_date: Time.zone.local(2024, 8, 8), end_date: Time.zone.local(2024, 8, 13)) }

        it "登録できない" do
          expect(special_day).not_to be_valid
          expect(special_day.errors[:base]).to include("既存の特別日と日付が重複しています")
        end
      end

      context "開始日から終了日までの期間が部分的に重複している場合" do
        let!(:special_day) { build(:special_day, start_date: Time.zone.local(2024, 8, 14), end_date: Time.zone.local(2024, 8, 16)) }

        it "登録できない" do
          expect(special_day).not_to be_valid
          expect(special_day.errors[:base]).to include("既存の特別日と日付が重複しています")
        end
      end

      context "開始日から終了日までの期間が完全に包含する場合" do
        let!(:special_day) { build(:special_day, start_date: Time.zone.local(2024, 8, 12), end_date: Time.zone.local(2024, 8, 19)) }

        it "登録できない" do
          expect(special_day).not_to be_valid
          expect(special_day.errors[:base]).to include("既存の特別日と日付が重複しています")
        end
      end

      context "開始日から終了日までの期間が全く重ならない場合" do
        let!(:special_day) { build(:special_day, start_date: Time.zone.local(2024, 8, 8), end_date: Time.zone.local(2024, 8, 10)) }

        it "登録できる" do
          expect(special_day).to be_valid
        end
      end
    end
  end
end
