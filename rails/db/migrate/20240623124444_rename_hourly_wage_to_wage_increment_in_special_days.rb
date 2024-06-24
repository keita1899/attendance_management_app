class RenameHourlyWageToWageIncrementInSpecialDays < ActiveRecord::Migration[6.0]
  def change
    rename_column :special_days, :hourly_wage, :wage_increment
  end
end