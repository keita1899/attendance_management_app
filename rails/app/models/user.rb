class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, authentication_keys: [:email]

  has_one :wage, dependent: :destroy
  has_many :attendances, dependent: :destroy

  ZENKAKU_REGEX = /\A[ぁ-んァ-ン一-龥々ー]+\z/
  KATAKANA_REGEX = /\A[ァ-ヶー－]+\z/

  validates :last_name, presence: true, format: { with: ZENKAKU_REGEX, message: "は全角で入力してください" }
  validates :first_name, presence: true, format: { with: ZENKAKU_REGEX, message: "は全角で入力してください" }
  validates :last_name_kana, presence: true, format: { with: KATAKANA_REGEX, message: "はカタカナで入力してください" }
  validates :first_name_kana, presence: true, format: { with: KATAKANA_REGEX, message: "はカタカナで入力してください" }
  validates :password_confirmation, presence: true

  def full_name
    last_name + first_name
  end

  def attended_dates
    attendances.where.not(clock_out_time: nil).pluck(:date).map(&:to_date).uniq
  end
end
