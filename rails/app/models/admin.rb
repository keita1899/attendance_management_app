class Admin < ApplicationRecord
  devise :database_authenticatable, :validatable, authentication_keys: [:name]

  validates :name, presence: true, uniqueness: true
  validates :password, presence: true

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def will_save_change_to_email?
    false
  end
end
