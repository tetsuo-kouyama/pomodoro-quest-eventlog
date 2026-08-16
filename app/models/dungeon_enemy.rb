class DungeonEnemy < ApplicationRecord
  include StatCalculatable

  HP_GROWTH  = 10
  ATK_GROWTH = 5
  DEF_GROWTH = 5
  SPD_GROWTH = 3

  belongs_to :dungeon
  belongs_to :monster

  validates :level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :encounter_weight, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :gold_reward, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :enemy_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :monster_id, uniqueness: { scope: [ :dungeon_id, :level, :enemy_count ] }

  def hp
    calculate_stat(monster.base_hp, level, HP_GROWTH)
  end

  def attack
    calculate_stat(monster.base_atk, level, ATK_GROWTH)
  end

  def defense
    calculate_stat(monster.base_def, level, DEF_GROWTH)
  end

  def speed
    calculate_stat(monster.base_speed, level, SPD_GROWTH)
  end

  def enemy_power
    hp + attack + defense + speed
  end

  def enemy_total_power
    enemy_power * enemy_count
  end
end
