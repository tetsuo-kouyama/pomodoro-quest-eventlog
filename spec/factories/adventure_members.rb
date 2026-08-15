FactoryBot.define do
  factory :adventure_member do
    association :owned_monster
    association :adventure

    sequence(:slot) { |n| n }
    max_hp { 10 }
    current_hp { 10 }
  end
end
