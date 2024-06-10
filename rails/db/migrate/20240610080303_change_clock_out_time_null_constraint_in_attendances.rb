class ChangeClockOutTimeNullConstraintInAttendances < ActiveRecord::Migration[7.0]
  def change
    change_column_null :attendances, :clock_out_time, true
  end
end
