class ChangeClockInTimeNullOnAttendances < ActiveRecord::Migration[7.0]
  def change
    change_column_null :attendances, :clock_in_time, true
  end
end
