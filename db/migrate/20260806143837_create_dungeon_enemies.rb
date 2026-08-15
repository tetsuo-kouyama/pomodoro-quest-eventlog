class CreateDungeonEnemies < ActiveRecord::Migration[7.2]
  def change
    create_table :dungeon_enemies do |t|
      t.references :dungeon, null: false, foreign_key: true
      t.references :monster, null: false, foreign_key: true
      t.integer :level, null: false
      t.integer :encounter_weight, null: false
      t.integer :gold_reward, null: false
      t.integer :enemy_count, null: false, default: 1

      t.timestamps
    end
    add_index :dungeon_enemies, [:dungeon_id, :monster_id, :level, :enemy_count], unique: true
  end
end
