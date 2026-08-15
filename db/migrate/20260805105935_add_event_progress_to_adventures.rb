class AddEventProgressToAdventures < ActiveRecord::Migration[7.2]
  def change
    add_column :adventures, :random_seed, :bigint, null: false
    add_column :adventures, :next_event_index, :integer, null: false, default: 1
  end
end
