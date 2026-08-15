class AddBaseSpeedToMonsters < ActiveRecord::Migration[7.2]
  def change
    add_column :monsters, :base_speed, :integer, null: false, default: 1
  end
end
