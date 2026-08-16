class Dungeon < ApplicationRecord
  has_many :adventures, dependent: :destroy
  has_many :users, through: :adventures
  has_many :dungeon_enemies, dependent: :destroy
  has_many :monsters, through: :dungeon_enemies

  # 前提ダンジョン
  belongs_to :prerequisite_dungeon,
             class_name: "Dungeon",
             optional: true

  # ダンジョンをクリアすると解放される次のダンジョン
  has_many :next_dungeons,
           class_name: "Dungeon",
           foreign_key: "prerequisite_dungeon_id",
           dependent: :nullify

  validates :name, presence: true
  validates :difficulty, presence: true, numericality: { greater_than: 0 }
  validates :battle_weight, :heal_weight, :treasure_weight, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :event_weights_must_have_positive_total
  validate :cannot_be_own_prerequisite

  def enemy_power
    difficulty * 50
  end

  private

  # 重みがあることを確認する
  def event_weights_must_have_positive_total
    return if battle_weight.nil? || heal_weight.nil? || treasure_weight.nil?

    total = battle_weight + heal_weight + treasure_weight

    if total.zero?
      errors.add(:base, "イベントの重みの合計は1以上である必要があります")
    end
  end

  # 自分自身を前提ダンジョンに設定できないようにする
  def cannot_be_own_prerequisite
    if prerequisite_dungeon_id.present? && prerequisite_dungeon_id == id
      error.add(:prerequisite_dungeon_id, "に自分自身を設定することはできません")
    end
  end
end
