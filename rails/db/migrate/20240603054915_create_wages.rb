class CreateWages < ActiveRecord::Migration[7.0]
  def change
    create_table :wages do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :weekday_rate, null: false, default: 0
      t.integer :weekend_rate, null: false, default: 0

      t.timestamps
    end
  end
end
