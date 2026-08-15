class RemoveRewardGoldFromDungeons < ActiveRecord::Migration[8.1]
  def change
    remove_column :dungeons, :reward_gold, :integer
  end
end
