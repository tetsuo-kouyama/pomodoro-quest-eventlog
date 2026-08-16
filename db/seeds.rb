# ==========================================
# 1. 本番・開発共通の「マスターデータ」（モンスター定義）
# ==========================================

monsters = [
  {
    id: 1,
    name: 'スライム',
    base_hp: 10,
    base_atk: 3,
    base_def: 1,
    base_speed: 1, 
    hire_cost: 50
  },
  {
    id: 2,
    name: 'ゴブリン',
    base_hp: 25,
    base_atk: 7,
    base_def: 3,
    base_speed: 3,
    hire_cost: 100
  }
]

monsters.each do |monster_data|
  monster = Monster.find_or_initialize_by(id: monster_data[:id])
  monster.update!(monster_data)
end
puts "🌱 Monster seed data loaded successfully! (Total: #{Monster.count})"

# ==========================================
# 2. 本番・開発共通の「マスターデータ」（ダンジョン定義）
# ==========================================

dungeons = [
  {
    id: 1,
    name: 'スライムの洞窟',
    difficulty: 1,
    prerequisite_dungeon_id: nil,
    battle_weight: 6,
    heal_weight: 2,
    treasure_weight: 2
  },
  {
    id: 2,
    name: 'ゴブリンの森',
    difficulty: 2,
    prerequisite_dungeon_id: 1,
    battle_weight: 6,
    heal_weight: 2,
    treasure_weight: 2
  }
]

dungeons.each do |dungeon_data|
  dungeon = Dungeon.find_or_initialize_by(id: dungeon_data[:id])
  dungeon.update!(dungeon_data)
end
puts "🏰 Dungeon seed data loaded successfully! (Total: #{Dungeon.count})"

# ==========================================
# 3. 本番・開発共通の「マスターデータ」（敵モンスター定義）
# ==========================================

dungeon_enemies = [
  {
    dungeon_id: 1,
    monster_id: 1,
    level: 1,
    encounter_weight: 60,
    gold_reward: 10,
    enemy_count: 1
  },
  {
    dungeon_id: 1,
    monster_id: 1,
    level: 1,
    encounter_weight: 35,
    gold_reward: 20,
    enemy_count: 2
  },
  {
    dungeon_id: 1,
    monster_id: 1,
    level: 1,
    encounter_weight: 5,
    gold_reward: 30,
    enemy_count: 3
  }
]

dungeon_enemies.each do |attributes|
  enemy = DungeonEnemy.find_or_initialize_by(
    dungeon_id: attributes[:dungeon_id],
    monster_id: attributes[:monster_id],
    level: attributes[:level],
    enemy_count: attributes[:enemy_count]
  )

  enemy.update!(
    encounter_weight: attributes[:encounter_weight],
    gold_reward: attributes[:gold_reward]
  )
end
puts "👾 DungeonEnemy seed data loaded successfully! (Total: #{DungeonEnemy.count})"
