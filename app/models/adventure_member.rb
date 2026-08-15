class AdventureMember < ApplicationRecord
  belongs_to :owned_monster
  belongs_to :adventure

  validates :slot, inclusion: { in: 1..OwnedMonster::MAX_PARTY_SIZE }
  validates :max_hp, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :current_hp, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
