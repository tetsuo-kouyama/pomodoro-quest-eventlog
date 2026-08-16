class AddPrerequisiteDungeonIdToDungeons < ActiveRecord::Migration[8.1]
  def change
    add_reference :dungeons,
                  :prerequisite_dungeon,
                  foreign_key: { to_table: :dungeons },
                  index: true
  end
end
