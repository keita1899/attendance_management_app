class CreateSpecialDays < ActiveRecord::Migration[7.0]
  def change
    create_table :special_days do |t|
      t.date "start_date", null: false
      t.date "end_date", null: false
      t.string "description", null: false
      t.integer "hourly_wage", default: 0, null: false
      t.integer "allowance", default: 0, null: false
      t.timestamps
    end
  end
end
