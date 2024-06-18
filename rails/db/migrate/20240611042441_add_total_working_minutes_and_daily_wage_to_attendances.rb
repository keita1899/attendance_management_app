class AddTotalWorkingMinutesAndDailyWageToAttendances < ActiveRecord::Migration[7.0]
  def change
    add_column :attendances, :total_working_minutes, :integer, null: false, default: 0, after: :overtime_minutes
    add_column :attendances, :daily_wage, :integer, null: false, default: 0, after: :hourly_wage
  end
end
