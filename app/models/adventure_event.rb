class AdventureEvent < ApplicationRecord
  belongs_to :adventure

  enum :event_type,
    {
      battle: "battle",
      heal: "heal",
      treasure: "treasure",
      boss: "boss"
    },
    validates: true

  validates :event_index,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :adventure_id }

  validates :occurred_after_seconds,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
