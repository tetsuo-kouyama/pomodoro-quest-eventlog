class RemoveDefaultFromMonstersBaseSpeed < ActiveRecord::Migration[7.2]
  def change
    change_column_default :monsters, :base_speed, from: 1, to: nil
  end
end
