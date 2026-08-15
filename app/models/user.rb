class User < ApplicationRecord
  has_secure_password

  has_many :owned_monsters, dependent: :destroy
  has_many :monsters, through: :owned_monsters

  has_many :adventures, dependent: :destroy
  has_many :dungeons, through: :adventures

  validates :name, presence: true, length: { maximum: 20 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, confirmation: true, allow_nil: true
  validates :gold, numericality: { greater_than_or_equal_to: 0 }

  def can_hire?(monster)
    gold >= monster.hire_cost
  end

  def hire_monster!(owned_monster, monster)
    raise InsufficientGoldError unless can_hire?(monster)

    transaction do
      decrement!(:gold, monster.hire_cost)
      owned_monster.save!
    end
  end

  # 冒険中または報酬未取得の冒険が存在するか？
  def incomplete_adventure?
    adventures.incomplete.exists?
  end

  # 進行中の冒険オブジェクトを取得
  def incomplete_adventure
    return @incomplete_adventure if defined?(@incomplete_adventure)

    @incomplete_adventure =
      adventures.incomplete.order(start_at: :desc).first
  end
end
