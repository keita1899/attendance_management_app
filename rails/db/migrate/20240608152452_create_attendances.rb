class CreateAttendances < ActiveRecord::Migration[7.0]
  def change
    create_table :attendances do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.time :clock_in_time, null: false
      t.time :clock_out_time, null: false
      t.integer :working_minutes, null: false, default: 0
      t.integer :overtime_minutes, null: false, default: 0
      t.integer :hourly_wage, null: false, default: 0
      t.integer :transport_cost, null: false, default: 0
      t.integer :allowance, null: false, default: 0
      t.integer :total_payment, null: false, default: 0
      t.boolean :special_day, null: false, default: false
      t.timestamps
    end
  end
end
