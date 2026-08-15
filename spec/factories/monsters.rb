FactoryBot.define do
  factory :monster do
    name { "スライム" }
    base_hp { 1 }
    base_atk { 1 }
    base_def { 1 }
    base_speed { 1 }
    hire_cost { 1 }
  end
end
