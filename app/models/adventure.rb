class Adventure < ApplicationRecord
  DURATIONS = [
    [ "1分", 1.minutes ],
    [ "25分", 25.minutes ],
    [ "60分", 60.minutes ],
    [ "90分", 90.minutes ]
  ].freeze

  DURATION_VALUES = DURATIONS.map(&:last).freeze
  WIPED_OUT_REWARD_DIVISOR = 10

  has_many :adventure_members, dependent: :destroy
  has_many :owned_monsters, through: :adventure_members
  has_many :adventure_events, dependent: :destroy
  belongs_to :user
  belongs_to :dungeon

  validates :required_time, inclusion: { in: DURATION_VALUES }
  validates :reward_gold, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :random_seed, numericality: { only_integer: true }
  validates :next_event_index, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  enum :status, {
    ongoing: 0,   # 冒険中
    victory: 1,   # 成功
    wiped_out: 2  # 失敗
  }

  # 進行中の冒険を取得する
  scope :ongoing, -> { where(status: :ongoing) }

  # 完了済みの冒険を取得する
  scope :finished, -> { where(status: %i[victory wiped_out]) }

  # 報酬が未受け取りの冒険を取得する
  scope :unclaimed, -> { finished.where(reward_claimed_at: nil) }

  # ユーザー側で処理が完了していない冒険(進行中または未受け取り)を取得する
  scope :incomplete, -> { ongoing.or(unclaimed) }

  # 残り時間を計算
  def remaining_seconds
    [ end_at - Time.current, 0 ].max
  end

  # 冒険が完了しているかを判定:削除予定
  def check_completion!
    if ongoing? && Time.current >= end_at
      finished!
    end
  end

  # 冒険を強制終了させる
  def force_finish(finished_at:)
    self.status = :wiped_out
    self.end_at = finished_at
  end

  # パーティの合計ステータス計算
  def total_party_power
    adventure_members.includes(owned_monster: :monster).sum do |member|
      member.owned_monster.total_power
    end
  end

  # クリアに必要な条件
  def enemy_power
    dungeon.difficulty * 100
  end

  # sakujoyotei
  def combat_victory?
    total_party_power >= dungeon.enemy_power
  end

  # 冒険に出発させるパーティメンバーと冒険データを紐付ける
  def assign_members(active_monsters)
    active_monsters.each do |monster|
      max_hp = monster.hp
      adventure_members.build(
        owned_monster_id: monster.id,
        slot: monster.party_position,
        current_hp: max_hp,
        max_hp: max_hp
      )
    end
  end

  # Adventure生成の初期化処理
  def prepare_for_departure!
    self.start_at = Time.current
    self.end_at = start_at + required_time.to_i
    self.reward_gold = 0
    self.status = :ongoing
    self.random_seed = SecureRandom.random_number(2**63)
    self.next_event_index = 1
  end

  # 冒険後の報酬決定
  def final_reward_gold
    return reward_gold if victory?
    return reward_gold / WIPED_OUT_REWARD_DIVISOR if wiped_out?
    0
  end

  # 「報酬を受け取りましたか？」
  def reward_claimed?
    reward_claimed_at.present?
  end

  # 「報酬を受け取れる状態ですか？」
  def reward_claimable?
    !ongoing? && !reward_claimed?
  end
end
