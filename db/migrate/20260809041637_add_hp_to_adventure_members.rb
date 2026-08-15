class AddHpToAdventureMembers < ActiveRecord::Migration[7.2]
  def change
    add_column :adventure_members, :current_hp, :integer
    add_column :adventure_members, :max_hp, :integer
    
    AdventureMember.find_each do |member|
      hp = member.owned_monster.hp
      member.update!(current_hp: hp, max_hp: hp)
    end
    
    change_column_null :adventure_members, :current_hp, false
    change_column_null :adventure_members, :max_hp, false
  end
end
