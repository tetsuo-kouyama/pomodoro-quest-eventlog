# ==========================================
# 1. 本番・開発共通の「マスターデータ」（ダンジョン定義）
# ==========================================

dungeons_data = [
  {
    name: 'スライムの洞窟',
    difficulty: 1,
    prerequisite_name: nil, # 前提ダンジョンなし
    battle_weight: 6, heal_weight: 2, treasure_weight: 2
  },
  {
    name: 'ゴブリンの森',
    difficulty: 2,
    prerequisite_name: 'スライムの洞窟',
    battle_weight: 6, heal_weight: 2, treasure_weight: 2
  }
]

dungeons_data.each do |data|
  # 前提ダンジョンの名前が指定されている場合、名前からオブジェクトを取得
  prerequisite = Dungeon.find_by(name: data[:prerequisite_name]) if data[:prerequisite_name]

  # name をキーにしてデータを取得または作成
  dungeon = Dungeon.find_or_initialize_by(name: data[:name])
  dungeon.update!(
    difficulty: data[:difficulty],
    prerequisite_dungeon: prerequisite, # IDの数値ではなくオブジェクトをセット
    battle_weight: data[:battle_weight],
    heal_weight: data[:heal_weight],
    treasure_weight: data[:treasure_weight]
  )
end
puts "🏰 Dungeon seed data loaded successfully! (Total: #{Dungeon.count})"

# ==========================================
# 2. 本番・開発共通の「マスターデータ」（モンスター定義）
# ==========================================

monsters_data = [
  {
    name: 'スライム',
    unlock_dungeon_name: nil,
    base_hp: 10, base_atk: 3, base_def: 1, base_speed: 1, hire_cost: 50
  },
  {
    name: 'ゴブリン',
    unlock_dungeon_name: 'ゴブリンの森', # 名前で参照！
    base_hp: 25, base_atk: 7, base_def: 3, base_speed: 3, hire_cost: 100
  }
]

monsters_data.each do |data|
  # 解放ダンジョンの名前からオブジェクトを取得
  unlock_dungeon = Dungeon.find_by(name: data[:unlock_dungeon_name]) if data[:unlock_dungeon_name]

  monster = Monster.find_or_initialize_by(name: data[:name])
  monster.update!(
    unlock_dungeon: unlock_dungeon, # IDの数値ではなくオブジェクトをセット
    base_hp: data[:base_hp],
    base_atk: data[:base_atk],
    base_def: data[:base_def],
    base_speed: data[:base_speed],
    hire_cost: data[:hire_cost]
  )
end
puts "🌱 Monster seed data loaded successfully! (Total: #{Monster.count})"

# ==========================================
# 3. 本番・開発共通の「マスターデータ」（敵モンスター定義）
# ==========================================

dungeon_enemies_data = [
  {
    dungeon_name: 'スライムの洞窟',
    monster_name: 'スライム',
    level: 1, encounter_weight: 60, gold_reward: 10, enemy_count: 1
  },
  {
    dungeon_name: 'スライムの洞窟',
    monster_name: 'スライム',
    level: 1, encounter_weight: 35, gold_reward: 20, enemy_count: 2
  },
  {
    dungeon_name: 'スライムの洞窟',
    monster_name: 'スライム',
    level: 1, encounter_weight: 5, gold_reward: 30, enemy_count: 3
  }
]

dungeon_enemies_data.each do |data|
  dungeon = Dungeon.find_by!(name: data[:dungeon_name])
  monster = Monster.find_by!(name: data[:monster_name])

  enemy = DungeonEnemy.find_or_initialize_by(
    dungeon: dungeon,
    monster: monster,
    level: data[:level],
    enemy_count: data[:enemy_count]
  )

  enemy.update!(
    encounter_weight: data[:encounter_weight],
    gold_reward: data[:gold_reward]
  )
end
puts "👾 DungeonEnemy seed data loaded successfully! (Total: #{DungeonEnemy.count})"
