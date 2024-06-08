class RenameRateColumnsInWages < ActiveRecord::Migration[7.0]
  def change
    rename_column :wages, :weekday_rate, :weekday_hourly_wage
    rename_column :wages, :weekend_rate, :weekend_hourly_wage
  end
end
