require 'rails_helper'

RSpec.describe 'Adventures', type: :request do
  describe 'POST /adventures' do
    let(:user) { create(:user) }
    let(:monster) { create(:monster) }
    let(:dungeon) { create(:dungeon) }
    let(:required_time) { 25.minutes }

    before { login(user) }

    context '入力が正常の場合' do
      it '冒険が成功する' do
        create_list(:owned_monster, 5, :party_member, user: user, monster: monster)

        expect do
          post adventures_path,
            params: {
              adventure: {
                dungeon_id: dungeon.id,
                required_time: required_time
              }
            }
        end.to change(Adventure, :count).by(1)
        .and change(AdventureMember, :count).by(5)

        adventure = Adventure.last

        expect(adventure.adventure_members.count).to eq(5)
        expect(adventure.status).to eq("ongoing")
        expect(adventure.end_at).to be_present
      end
    end

    context '入力が不正の場合' do
      it 'パーティが空の時に失敗する' do
        expect do
          post adventures_path,
            params: {
              adventure: {
                dungeon_id: dungeon.id,
                required_time: required_time
              }
            }
        end.not_to change(Adventure, :count)

        expect(response).to redirect_to(new_adventure_path)
      end

      it 'ダンジョンが空の時に失敗する' do
        create_list(:owned_monster, 5, :party_member, user: user, monster: monster)
        expect do
          post adventures_path,
            params: {
              adventure: {
                required_time: required_time
              }
            }
        end.not_to change(Adventure, :count)

        expect(response).to redirect_to(new_adventure_path)
        expect(flash[:alert]).to eq("このダンジョンは存在しないか、まだ解放されていません")
      end

      it '冒険時間が空の時に失敗する' do
        create_list(:owned_monster, 5, :party_member, user: user, monster: monster)
        expect do
          post adventures_path,
            params: {
              adventure: {
                dungeon_id: dungeon.id
              }
            }
        end.not_to change(Adventure, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context '既に冒険中の場合' do
      let!(:adventure) { create(:adventure, :ongoing, :with_members, user: user) }

      it '新たに冒険できない' do
        expect do
          post adventures_path,
            params: {
              adventure: {
                dungeon_id: dungeon.id,
                required_time: required_time
              }
            }
        end.not_to change(Adventure, :count)

        expect(response).to redirect_to(adventure_path(adventure))
        expect(flash[:alert]).to eq("進行中または報酬を受け取っていない冒険があります")
      end
    end

    context '解放済みダンジョンの場合' do
      let(:prerequisite_dungeon) { create(:dungeon, name: "スライムの洞窟", difficulty: 1) }
      let(:unlocked_dungeon) { create(:dungeon, name: "ゴブリンの森", difficulty: 2, prerequisite_dungeon: prerequisite_dungeon) }

      before do
        create(:adventure, :victory, :reward_claimed, user: user, dungeon: prerequisite_dungeon)
        create_list(:owned_monster, 5, :party_member, user: user, monster: monster)
      end

      it "冒険を作成できる" do
        expect do
          post adventures_path,
            params: {
              adventure: {
                dungeon_id: unlocked_dungeon.id,
                required_time: required_time
              }
            }
        end.to change(Adventure, :count).by(1)

        adventure = Adventure.last

        expect(adventure.user).to eq(user)
        expect(adventure.dungeon).to eq(unlocked_dungeon)
        expect(response).to redirect_to(adventure_path(adventure))
      end
    end

    context '解放済みでないダンジョンの場合' do
      let(:prerequisite_dungeon) { create(:dungeon, name: "スライムの洞窟", difficulty: 1) }
      let(:locked_dungeon) { create(:dungeon, name: "ゴブリンの森", difficulty: 2, prerequisite_dungeon: prerequisite_dungeon) }

      before do
        create(:adventure, :wiped_out, :reward_claimed, user: user, dungeon: prerequisite_dungeon)
        create_list(:owned_monster, 5, :party_member, user: user, monster: monster)
      end

      it "冒険を作成できない" do
        expect do
          post adventures_path,
            params: {
              adventure: {
                dungeon_id: locked_dungeon.id,
                required_time: required_time
              }
            }
        end.not_to change(Adventure, :count)

        expect(flash[:alert]).to eq("このダンジョンは存在しないか、まだ解放されていません")
        expect(response).to redirect_to(new_adventure_path)
      end
    end
  end
end
