require 'rails_helper'

RSpec.describe Dungeon, type: :model do
  describe 'バリデーション' do
    describe 'name' do
      context '有効の場合' do
        it '名前がある' do
          dungeon = build(:dungeon, name: 'テストダンジョン')
          expect(dungeon).to be_valid
        end
      end

      context '無効の場合' do
        it '値がnil' do
          dungeon = build(:dungeon, name: nil)
          expect(dungeon).to be_invalid
        end
      end
    end

    describe 'difficulty' do
      context '有効の場合' do
        it '値が1以上' do
          dungeon = build(:dungeon, difficulty: 1)
          expect(dungeon).to be_valid
        end
      end

      context '無効の場合' do
        it '値が0' do
          dungeon = build(:dungeon, difficulty: 0)
          expect(dungeon).to be_invalid
        end

        it '値が負数' do
          dungeon = build(:dungeon, difficulty: -1)
          expect(dungeon).to be_invalid
        end

        it '値がnil' do
          dungeon = build(:dungeon, difficulty: nil)
          expect(dungeon).to be_invalid
        end
      end
    end
  end
end
