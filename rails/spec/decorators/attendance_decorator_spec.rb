require "rails_helper"

RSpec.describe AttendanceDecorator do
  subject { attendance.decorate }

  let!(:user) { create(:user) }
  let!(:attendance) { build(:attendance, clock_in_time: nil, clock_out_time: nil, user:) }

  describe "#today?" do
    context "日付が今日の場合" do
      let!(:attendance) { build(:attendance, date: Time.zone.today, user:) }

      it "trueを返す" do
        expect(subject.today?).to be true
      end
    end

    context "日付が今日ではない場合" do
      let!(:attendance) { build(:attendance, date: Time.zone.today - 1.day, user:) }

      it "falseを返す" do
        expect(subject.today?).to be false
      end
    end
  end

  describe "can_clock_in?" do
    context "まだ出勤していない場合" do
      context "現在の時間が9時29分のとき" do
        before { travel_to(Time.zone.local(2024, 6, 14, 9, 29, 0)) }

        it "falseを返す" do
          expect(subject.can_clock_in?).to be false
        end
      end

      context "現在の時間が9時30分の時" do
        before { travel_to(Time.zone.local(2024, 6, 14, 9, 30, 0)) }

        it "trueを返す" do
          expect(subject.can_clock_in?).to be true
        end
      end

      context "現在の時間が10時00分の時" do
        before { travel_to(Time.zone.local(2024, 6, 14, 10, 0, 0)) }

        it "trueを返す" do
          expect(subject.can_clock_in?).to be true
        end
      end
    end

    context "すでに出勤している場合" do
      let!(:attendance) { build(:attendance, user:) }

      it "falseを返す" do
        expect(subject.can_clock_in?).to be false
      end
    end
  end

  describe "can_clock_out?" do
    context "まだ出勤も退勤もしていない場合" do
      it "falseを返す" do
        expect(subject.can_clock_out?).to be false
      end
    end

    context "すでに出勤していてまだ退勤していない場合" do
      let!(:attendance) { build(:attendance, clock_out_time: nil, user:) }

      it "trueを返す" do
        expect(subject.can_clock_out?).to be true
      end
    end

    context "すでに退勤している場合" do
      let!(:attendance) { build(:attendance, user:) }

      it "falseを返す" do
        expect(subject.can_clock_out?).to be false
      end
    end
  end

  describe "day_of_week" do
    context "平日（月曜日）の場合" do
      it "月を返す" do
        date = Time.zone.local(2024, 6, 10)
        expect(subject.day_of_week(date)).to eq("月")
      end
    end

    context "平日（火曜日）の場合" do
      it "火を返す" do
        date = Time.zone.local(2024, 6, 11)
        expect(subject.day_of_week(date)).to eq("火")
      end
    end

    context "平日（水曜日）の場合" do
      it "水を返す" do
        date = Time.zone.local(2024, 6, 12)
        expect(subject.day_of_week(date)).to eq("水")
      end
    end

    context "平日（木曜日）の場合" do
      it "木を返す" do
        date = Time.zone.local(2024, 6, 13)
        expect(subject.day_of_week(date)).to eq("木")
      end
    end

    context "平日（金曜日）の場合" do
      it "金を返す" do
        date = Time.zone.local(2024, 6, 14)
        expect(subject.day_of_week(date)).to eq("金")
      end
    end

    context "土曜日の場合" do
      it "土を返す" do
        date = Time.zone.local(2024, 6, 15)
        expect(subject.day_of_week(date)).to eq("土")
      end
    end

    context "日曜日の場合" do
      it "日を返す" do
        date = Time.zone.local(2024, 6, 16)
        expect(subject.day_of_week(date)).to eq("日")
      end
    end
  end

  describe "#status" do
    subject { attendance.decorate }

    context "未出勤の場合" do
      let!(:attendance) { build(:attendance, date: Date.current, clock_in_time: nil, clock_out_time: nil, user:) }

      it "未出勤のバッジのHTMLを返す" do
        expect(subject.status).to eq('<span class="badge bg-secondary">未出勤</span>'.html_safe)
      end
    end

    context "出勤中の場合" do
      let!(:attendance) { build(:attendance, date: Date.current, clock_in_time: Time.current.change(hour: 10, min: 0), clock_out_time: nil, user:) }

      it "出勤中のバッジのHTMLを返す" do
        expect(subject.status).to eq('<span class="badge bg-success">出勤中</span>'.html_safe)
      end
    end

    context "退勤済の場合" do
      let!(:attendance) {
        build(:attendance, date: Date.current, clock_in_time: Time.current.change(hour: 10, min: 0), clock_out_time: Time.current.change(hour: 14, min: 0),
                           user:)
      }

      it "退勤済のバッジのHTMLを返す" do
        expect(subject.status).to eq('<span class="badge bg-dark">退勤済</span>'.html_safe)
      end
    end
  end
end
