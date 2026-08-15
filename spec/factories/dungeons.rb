FactoryBot.define do
  factory :dungeon do
    name { "test_dungeon" }
    difficulty { 1 }
    battle_weight { 6 }
    heal_weight { 2 }
    treasure_weight { 2 }
  end
end
