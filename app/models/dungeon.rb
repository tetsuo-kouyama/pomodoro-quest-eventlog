class Dungeon < ApplicationRecord
  has_many :adventures, dependent: :destroy
  has_many :users, through: :adventures
  has_many :dungeon_enemies, dependent: :destroy
  has_many :monsters, through: :dungeon_enemies

  validates :name, presence: true
  validates :difficulty, presence: true, numericality: { greater_than: 0 }
  validates :battle_weight, :heal_weight, :treasure_weight, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :event_weights_must_have_positive_total

  def enemy_power
    difficulty * 50
  end

  private

  def event_weights_must_have_positive_total
    return if battle_weight.nil? || heal_weight.nil? || treasure_weight.nil?

    total = battle_weight + heal_weight + treasure_weight

    if total.zero?
      errors.add(:base, "イベントの重みの合計は1以上である必要があります")
    end
  end
end
