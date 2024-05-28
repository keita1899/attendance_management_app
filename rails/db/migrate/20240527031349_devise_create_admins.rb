# frozen_string_literal: true

class DeviseCreateAdmins < ActiveRecord::Migration[7.0]
  def change
    create_table :admins do |t|
      ## Database authenticatable
      t.string :name, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.timestamps null: false
    end

    add_index :admins, :name, unique: true
  end
end
