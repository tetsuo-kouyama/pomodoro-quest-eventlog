# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_15_154814) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "adventure_events", force: :cascade do |t|
    t.bigint "adventure_id", null: false
    t.datetime "created_at", null: false
    t.integer "event_index", null: false
    t.string "event_type", null: false
    t.integer "occurred_after_seconds", null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["adventure_id", "event_index"], name: "index_adventure_events_on_adventure_id_and_event_index", unique: true
    t.index ["adventure_id", "occurred_after_seconds"], name: "idx_on_adventure_id_occurred_after_seconds_5527aabe10"
    t.index ["adventure_id"], name: "index_adventure_events_on_adventure_id"
  end

  create_table "adventure_members", force: :cascade do |t|
    t.bigint "adventure_id", null: false
    t.datetime "created_at", null: false
    t.integer "current_hp", null: false
    t.integer "max_hp", null: false
    t.bigint "owned_monster_id", null: false
    t.integer "slot", null: false
    t.datetime "updated_at", null: false
    t.index ["adventure_id", "owned_monster_id"], name: "index_adventure_members_on_adventure_id_and_owned_monster_id", unique: true
    t.index ["adventure_id"], name: "index_adventure_members_on_adventure_id"
    t.index ["owned_monster_id"], name: "index_adventure_members_on_owned_monster_id"
  end

  create_table "adventures", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "dungeon_id", null: false
    t.datetime "end_at", null: false
    t.integer "next_event_index", default: 1, null: false
    t.bigint "random_seed", null: false
    t.integer "required_time", null: false, comment: "seconds"
    t.datetime "reward_claimed_at"
    t.integer "reward_gold", null: false
    t.datetime "start_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["dungeon_id"], name: "index_adventures_on_dungeon_id"
    t.index ["user_id"], name: "index_adventures_on_user_id"
  end

  create_table "dungeon_enemies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "dungeon_id", null: false
    t.integer "encounter_weight", null: false
    t.integer "enemy_count", default: 1, null: false
    t.integer "gold_reward", null: false
    t.integer "level", null: false
    t.bigint "monster_id", null: false
    t.datetime "updated_at", null: false
    t.index ["dungeon_id", "monster_id", "level", "enemy_count"], name: "idx_on_dungeon_id_monster_id_level_enemy_count_1fab9f8f9e", unique: true
    t.index ["dungeon_id"], name: "index_dungeon_enemies_on_dungeon_id"
    t.index ["monster_id"], name: "index_dungeon_enemies_on_monster_id"
  end

  create_table "dungeons", force: :cascade do |t|
    t.integer "battle_weight", default: 60, null: false
    t.datetime "created_at", null: false
    t.integer "difficulty", null: false
    t.integer "heal_weight", default: 20, null: false
    t.string "name", null: false
    t.bigint "prerequisite_dungeon_id"
    t.integer "treasure_weight", default: 20, null: false
    t.datetime "updated_at", null: false
    t.index ["prerequisite_dungeon_id"], name: "index_dungeons_on_prerequisite_dungeon_id"
  end

  create_table "monsters", force: :cascade do |t|
    t.integer "base_atk", null: false
    t.integer "base_def", null: false
    t.integer "base_hp", null: false
    t.integer "base_speed", null: false
    t.datetime "created_at", null: false
    t.integer "hire_cost", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "owned_monsters", force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "level", default: 1, null: false
    t.bigint "monster_id", null: false
    t.string "nickname"
    t.integer "party_position"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["monster_id"], name: "index_owned_monsters_on_monster_id"
    t.index ["user_id"], name: "index_owned_monsters_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.integer "gold", default: 100, null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "adventure_events", "adventures"
  add_foreign_key "adventure_members", "adventures"
  add_foreign_key "adventure_members", "owned_monsters"
  add_foreign_key "adventures", "dungeons"
  add_foreign_key "adventures", "users"
  add_foreign_key "dungeon_enemies", "dungeons"
  add_foreign_key "dungeon_enemies", "monsters"
  add_foreign_key "dungeons", "dungeons", column: "prerequisite_dungeon_id"
  add_foreign_key "owned_monsters", "monsters"
  add_foreign_key "owned_monsters", "users"
end
