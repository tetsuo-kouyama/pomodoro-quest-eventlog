FactoryBot.define do
  factory :dungeon do
    sequence(:name) { |n| "test_dungeon_#{n}" }
    difficulty { 1 }
    battle_weight { 6 }
    heal_weight { 2 }
    treasure_weight { 2 }

    trait :with_prerequisite do
      association :prerequisite_dungeon, factory: :dungeon
    end
  end
end
