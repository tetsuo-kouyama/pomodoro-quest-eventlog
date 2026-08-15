require 'rails_helper'

RSpec.describe Adventure, type: :model do
  describe 'バリデーション' do
    describe 'required_time' do
      context '有効の場合' do
        it '指定した値' do
          adventure = build(:adventure, required_time: Adventure::DURATION_VALUES.first)
          expect(adventure).to be_valid
        end
      end

      context '無効の場合' do
        it '値が0' do
          adventure = build(:adventure, required_time: 0.minutes)
          expect(adventure).to be_invalid
        end

        it '指定した値ではない' do
          adventure = build(:adventure, required_time: 30.minutes)
          expect(adventure).to be_invalid
        end
      end
    end

    describe 'reward_gold' do
      context '有効の場合' do
        it '1以上の数値' do
          adventure = build(:adventure, reward_gold: 1)
          expect(adventure).to be_valid
        end

        it '値が0' do
          adventure = build(:adventure, reward_gold: 0)
          expect(adventure).to be_valid
        end
      end

      context '無効の場合' do
        it '値が負数' do
          adventure = build(:adventure, reward_gold: -1)
          expect(adventure).to be_invalid
        end
      end
    end
  end

  describe '#remaining_seconds' do
    it '残り秒数を返す' do
      adventure = build(:adventure, end_at: 10.minutes.from_now)

      expect(adventure.remaining_seconds).to be_between(599, 600)
    end
  end
end
