class OwnedMonster < ApplicationRecord
  include StatCalculatable

  MAX_PARTY_SIZE = 5
  MAX_LEVEL = 10
  MAX_MONSTER_COUNT = 10

  before_validation :set_default_nickname
  before_destroy :ensure_not_last_monster

  has_many :adventure_members, dependent: :destroy
  has_many :adventures, through: :adventure_members
  belongs_to :user
  belongs_to :monster

  validates :nickname, length: { maximum: 20 }, allow_blank: true
  validates :level, numericality: { less_than_or_equal_to: MAX_LEVEL }
  validates :party_position, uniqueness: { scope: :user_id }, allow_nil: true
  validate :check_monster_limit, on: :create


  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def hp
    calculate_stat(monster.base_hp, level, hp_growth)
  end

  def attack
    calculate_stat(monster.base_atk, level, atk_growth)
  end

  def defense
    calculate_stat(monster.base_def, level, def_growth)
  end

  def speed
    calculate_stat(monster.base_speed, level, spd_growth)
  end

  def total_power
    hp + defense + attack
  end

  def increment_level!(user)
    raise LevelMaxReachedError if level >= MAX_LEVEL
    raise InsufficientGoldError if user.gold < next_level_cost
    transaction do
      user.decrement!(:gold, next_level_cost)
      increment!(:level)
    end
  end

  def next_level_cost
    (level + 1) * monster.hire_cost
  end

  def locked_for_adventure?
    user.incomplete_adventure? && active?
  end

  def only_monster?
    user.owned_monsters.count <= 1
  end

  def level_max?
    level >= MAX_LEVEL
  end

  private

  def set_default_nickname
    self.nickname = monster.name if nickname.blank?
  end

  def hp_growth
    10
  end

  def atk_growth
    5
  end

  def def_growth
    5
  end

  def spd_growth
    3
  end

  def ensure_not_last_monster
    return unless only_monster?

    errors.add(:base, "最後のモンスターは解雇できません")
    throw(:abort)
  end

  def check_monster_limit
    return if user.owned_monsters.count < MAX_MONSTER_COUNT

    errors.add(:base, "モンスターの雇用上限（#{MAX_MONSTER_COUNT}体）に達しています")
  end
end
