class AddRewardClaimedAtToAdventures < ActiveRecord::Migration[7.2]
  def change
    add_column :adventures, :reward_claimed_at, :datetime
  end
end
