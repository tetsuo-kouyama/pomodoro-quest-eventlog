require 'rails_helper'

RSpec.describe 'Adventures', type: :system do
  let(:user) { create(:user) }
  let(:monster) { create(:monster) }
  let!(:dungeon) { create(:dungeon) }

  before do
    login(user)
  end

  describe '冒険作成機能' do
    context '入力が正常' do
      let!(:owned_monster) { create(:owned_monster, :party_member, user: user, monster: monster) }

      it '冒険の作成に成功する' do
        visit new_adventure_path
        select "#{dungeon.name} (敵の強さ: #{dungeon.enemy_total_power_range})", from: 'ダンジョン'
        select '25分', from: '冒険時間'

        # submitボタン取得が不安定なため requestSubmit() を使用
        page.execute_script("document.getElementById('adventure-form').requestSubmit()")

        expect(page).to have_current_path(new_adventure_path)
        expect(page).to have_content('冒険に出発しました')
      end
    end

    context 'パーティが空' do
      it '冒険の作成に失敗する' do
        visit new_adventure_path
        select "#{dungeon.name} (敵の強さ: #{dungeon.enemy_total_power_range})", from: 'ダンジョン'
        select '25分', from: '冒険時間'

        page.execute_script("document.getElementById('adventure-form').requestSubmit()")

        expect(page).to have_current_path(new_adventure_path)
        expect(page).to have_content('パーティを編成してください')
      end
    end
  end
end
