require 'rails_helper'

RSpec.describe 'OwnedMonsters', type: :request do
  let(:user) { create(:user) }

  describe 'GET /owned_monsters' do
    context 'ログイン済み' do
      it '一覧画面を表示できる' do
        login(user)
        get "/owned_monsters"
        expect(response).to have_http_status(:success)
      end
    end

    context '未ログイン' do
      it 'ログイン画面へリダイレクトされる' do
        get "/owned_monsters"
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'POST /owned_monsters' do
    let(:user) { create(:user, gold: 100) }
    let(:monster) { create(:monster, hire_cost: 100) }

    before { login(user) }

    context 'ゴールドが足りている' do
      it '雇用できる' do
        expect do
          post owned_monsters_path,
            params: {
              owned_monster: {
                monster_id: monster.id
              }
            }
        end.to change(OwnedMonster, :count).by(1)

        expect(user.reload.gold).to eq(0)
        expect(response).to redirect_to(owned_monsters_path)
      end
    end

    context 'ゴールドが不足している' do
      let(:user) { create(:user, gold: 50) }

      it '雇用できない' do
        expect do
          post owned_monsters_path,
            params: {
              owned_monster: {
                monster_id: monster.id
              }
            }
        end.not_to change(OwnedMonster, :count)

        expect(user.reload.gold).to eq(50)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET /owned_monsters/:id' do
    let(:owned_monster) { create(:owned_monster, user: user) }

    before { login(user) }

    it 'モンスター詳細画面を表示' do
      get owned_monster_path(owned_monster)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /owned_monsters/:id/levelup' do
    let(:user) { create(:user, gold: 200) }
    let(:monster) { create(:monster, hire_cost: 100) }
    let(:owned_monster) { create(:owned_monster, user: user, monster: monster) }

    before { login(user) }

    context 'ゴールドが足りている' do
      it 'レベルが1上がる' do
        expect do
          post levelup_owned_monster_path(owned_monster)
        end.to change { owned_monster.reload.level }
        expect(user.reload.gold).to eq(0)
        expect(response).to redirect_to(owned_monster_path(owned_monster))
      end
    end

    context 'ゴールドが不足している' do
      let(:user) { create(:user, gold: 100) }

      it 'レベルが上がらない' do
        expect do
          post levelup_owned_monster_path(owned_monster)
        end.not_to change { owned_monster.reload.level }
        expect(user.reload.gold).to eq(100)
        expect(response).to redirect_to(owned_monster_path(owned_monster))
      end
    end
  end

  describe 'DELETE /owned_monsters/:id' do
    let!(:owned_monster) { create(:owned_monster, user: user) }

    before { login(user) }

    context 'モンスターが2体以上' do
      it 'モンスターを削除できる' do
        delete_monster = create(:owned_monster, user: user)
        expect do
          delete owned_monster_path(delete_monster)
        end.to change(OwnedMonster, :count).by(-1)
        expect(response).to redirect_to(owned_monsters_path)
        expect(OwnedMonster.exists?(delete_monster.id)).to be(false)
        expect(response).to have_http_status(:see_other)
      end
    end

    context 'モンスターが1体のみ' do
      it 'モンスターを削除できない' do
        expect do
          delete owned_monster_path(owned_monster)
        end.not_to change(OwnedMonster, :count)
        expect(response).to redirect_to(owned_monster_path(owned_monster))
      end
    end
  end

  describe '冒険中モンスターへの操作制限' do
    let(:user) { create(:user, gold: 100) }
    let!(:adventure) { create(:adventure, :ongoing, :with_member, user: user) }
    let(:adventuring_monster) { adventure.adventure_members.first.owned_monster }

    before { login(user) }

    it 'レベルアップできない' do
      expect do
        post levelup_owned_monster_path(adventuring_monster)
      end.not_to change { adventuring_monster.reload.level }
      expect(response).to redirect_to(owned_monster_path(adventuring_monster))
      expect(user.reload.gold).to eq(100)
    end

    it '削除できない' do
      expect do
        delete owned_monster_path(adventuring_monster)
      end.not_to change(OwnedMonster, :count)
      expect(response).to redirect_to(owned_monster_path(adventuring_monster))
    end
  end
end
