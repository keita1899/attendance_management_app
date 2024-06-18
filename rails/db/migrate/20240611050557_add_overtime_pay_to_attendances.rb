class AddOvertimePayToAttendances < ActiveRecord::Migration[7.0]
  def change
    add_column :attendances, :overtime_pay, :integer, null: false, default:0, after: :daily_wage
  end
end
