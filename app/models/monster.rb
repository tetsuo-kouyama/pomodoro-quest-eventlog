class Monster < ApplicationRecord
  has_many :owned_monsters, dependent: :destroy
  has_many :users, through: :owned_monsters
  has_many :dungeon_enemies, dependent: :restrict_with_error
  has_many :dungeons, through: :dungeon_enemies

  # このモンスターを解放する前提ダンジョン
  belongs_to :unlock_dungeon, class_name: "Dungeon", optional: true

  validates :name, presence: true
  validates :base_hp, :base_atk, :base_def, :base_speed, :hire_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
