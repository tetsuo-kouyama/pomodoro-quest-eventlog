FactoryBot.define do
  factory :adventure do
    association :user
    association :dungeon

    required_time { 25.minutes }
    reward_gold { 100 }
    start_at { Time.current }
    end_at { start_at + required_time }
    status { :ongoing }
    reward_claimed_at { nil }
    random_seed { 1 }
    next_event_index { 1 }

    # 進行中
    trait :ongoing do
      status { :ongoing }
    end

    # 勝利
    trait :victory do
      status { :victory }
    end

    # 敗北
    trait :wiped_out do
      status { :wiped_out }
    end

    # 報酬取得済み
    trait :reward_claimed do
      reward_claimed_at { Time.current }
    end

    # 複数のパーティメンバー
    trait :with_members do
      after(:create) do |adventure|
        monsters = create_list(:owned_monster, 5, :party_member, user: adventure.user)

        monsters.each do |monster|
          create(
            :adventure_member,
            adventure: adventure,
            owned_monster: monster,
            slot: monster.party_position
          )
        end
      end
    end

    # 単体のパーティメンバー
    trait :with_member do
      after(:create) do |adventure|
        party_monster = create(
          :owned_monster,
          :party_member,
          user: adventure.user
        )

        create(
          :adventure_member,
          adventure: adventure,
          owned_monster: party_monster
        )
      end
    end
  end
end
