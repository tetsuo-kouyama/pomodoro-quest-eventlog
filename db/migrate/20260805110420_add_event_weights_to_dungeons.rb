class AddEventWeightsToDungeons < ActiveRecord::Migration[7.2]
  def change
    add_column :dungeons,
               :battle_weight,
               :integer,
               null: false,
               default: 60

    add_column :dungeons,
               :heal_weight,
               :integer,
               null: false,
               default: 20

    add_column :dungeons,
               :treasure_weight,
               :integer,
               null: false,
               default: 20
  end
end
