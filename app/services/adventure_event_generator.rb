require "digest"

class AdventureEventGenerator
  EVENT_INTERVAL_SECONDS = 60
  DEFAULT_HEAL_AMOUNT = 100
  TREASURE_GOLD_MULTIPLIER = 50

  def initialize(adventure, current_time: Time.current)
    @adventure = adventure
    @current_time = current_time
  end

  def call
    generated_events = []

    Adventure.transaction do
      adventure.lock!

      while adventure.next_event_index <= available_event_count
        event_index = adventure.next_event_index
        event = generate_event(event_index)
        generated_events << event

        adventure.next_event_index += 1

        if adventure_wiped_out?
          finished_at =
            adventure.start_at + event_index * EVENT_INTERVAL_SECONDS

          adventure.force_finish(finished_at: finished_at)
          break
        end
      end

      adventure.save!
    end

    generated_events
  end

  private

  attr_reader :adventure, :current_time

  # 最大イベント数を計算する(冒険時間 / イベント間隔)
  def total_event_count
    adventure.required_time / EVENT_INTERVAL_SECONDS
  end

  # 現在までの経過秒数を計算する
  def elapsed_seconds
    # 冒険終了後にアクセスしてもend_atまでしか進行しない
    processing_time = [ current_time, adventure.end_at ].min
    [ (processing_time - adventure.start_at).to_i, 0 ].max
  end

  # 発生するイベント数を計算する
  def available_event_count
    [
      elapsed_seconds / EVENT_INTERVAL_SECONDS,
      total_event_count
    ].min
  end

  # イベントを一件生成する
  def generate_event(event_index)
    event_type = event_type_for(event_index)

    AdventureEvent.create!(
      adventure: adventure,
      event_index: event_index,
      occurred_after_seconds: event_index * EVENT_INTERVAL_SECONDS,
      event_type: event_type,
      payload: payload_for(event_type, event_index)
    )
  end

  # イベントタイプを決める(最後はボスイベント)
  def event_type_for(event_index)
    if event_index == total_event_count
      "boss"
    else
      choose_random_event_type(event_index)
    end
  end

  # イベントごとの処理を振り分ける
  def payload_for(event_type, event_index)
    case event_type
    when "battle"
      battle_payload(event_index)
    when "heal"
      heal_payload(event_index)
    when "treasure"
      treasure_payload
    when "boss"
      boss_payload(event_index)
    else
      {}
    end
  end

  # 回復イベント
  def heal_payload(event_index)
    candidates = adventure.adventure_members.reload.select do |member|
      member.current_hp.positive? && member.current_hp < member.max_hp
    end

    target = candidates.sample(random: random_for(event_index))
    return { message: "休憩の必要はないと判断し、泉を後にした" } if target.nil?

    heal_amount = target.max_hp - target.current_hp
    nickname = target.owned_monster.nickname

    target.update!(current_hp: target.max_hp)

    {
      owned_monster_id: target.owned_monster_id,
      monster_name: nickname,
      heal_amount: heal_amount,
      message: "#{nickname}は水を飲んだ...\n#{nickname}のHPが#{heal_amount}回復した！"
    }
  end

  # 宝箱イベント
  def treasure_payload
    gold = adventure.dungeon.difficulty * TREASURE_GOLD_MULTIPLIER
    adventure.reward_gold += gold

    {
      gold: gold,
      message: "#{gold}Gを手に入れた！"
    }
  end

  # 戦闘イベント
  def battle_payload(event_index)
    # 1, 今回遭遇する敵を抽選
    dungeon_enemy = choose_dungeon_enemy(event_index, purpose: "battle")

    # 2, Randomオブジェクトを作成
    random = random_for(event_index)

    # 3, 戦闘を実行
    result = BattleSimulator.new(
      adventure: adventure,
      dungeon_enemy: dungeon_enemy,
      random: random
    ).call

    # 4, 戦闘勝利時の報酬を獲得
    gold_reward = result[:victory] ? dungeon_enemy.gold_reward : 0
    adventure.reward_gold += gold_reward

    # 5, 戦闘時点の情報を結果をイベントに保存
    # dungeon_enemy_id と monster_id は将来性を考慮して残しておく
    {
      dungeon_enemy_id: dungeon_enemy.id,
      monster_id: dungeon_enemy.monster.id,
      monster_name: dungeon_enemy.monster.name,
      level: dungeon_enemy.level,
      enemy_count: dungeon_enemy.enemy_count,
      gold_reward: gold_reward,
      victory: result[:victory],
      logs: result[:logs]
    }
  end

  # ボスイベント
  def boss_payload(event_index)
    dungeon_enemy = choose_boss_enemy
    random = random_for(event_index)

    result = BattleSimulator.new(
      adventure: adventure,
      dungeon_enemy: dungeon_enemy,
      random: random
    ).call

    gold_reward = result[:victory] ? dungeon_enemy.gold_reward : 0
    adventure.reward_gold += gold_reward

    adventure.status = :victory if result[:victory]

    {
      dungeon_enemy_id: dungeon_enemy.id,
      monster_id: dungeon_enemy.monster.id,
      monster_name: dungeon_enemy.monster.name,
      level: dungeon_enemy.level,
      enemy_count: dungeon_enemy.enemy_count,
      gold_reward: gold_reward,
      victory: result[:victory],
      logs: result[:logs]
    }
  end

  # 敵データから出現数が最も多いパターンをボスとして抽出
  def choose_boss_enemy
    adventure.dungeon.dungeon_enemies.order(enemy_count: :desc).first
  end

  # イベントの重みをハッシュにする
  def event_weights
    {
      "battle" => adventure.dungeon.battle_weight,
      "heal" => adventure.dungeon.heal_weight,
      "treasure" => adventure.dungeon.treasure_weight
    }
  end

  # イベントの重み付き抽選
  def choose_random_event_type(event_index)
    weights = event_weights
    total_weight = weights.values.sum
    random_value = random_for(event_index).rand(total_weight)

    weights.each do |event_type, weight|
      return event_type if random_value < weight

      random_value -= weight
    end

    raise "イベントタイプを抽選できませんでした"
  end

  # イベントごとに再現可能な乱数を作成する
  def random_for(event_index)
    source = "#{adventure.random_seed}:#{event_index}"

    event_seed = Digest::SHA256.hexdigest(source).to_i(16) % (2**63)

    Random.new(event_seed)
  end

  # 敵編成の重み付き抽選
  def choose_dungeon_enemy(event_index, purpose: "battle")
    candidates = adventure.dungeon.dungeon_enemies.includes(:monster).to_a

    raise "出現可能な敵が設定されていません" if candidates.empty?

    total_weight = candidates.sum(&:encounter_weight)
    random_value = random_for_enemy(event_index, purpose: purpose).rand(total_weight)

    candidates.each do |candidate|
      return candidate if random_value < candidate.encounter_weight

      random_value -= candidate.encounter_weight
    end

    raise "敵編成を抽出できませんでした"
  end

  # 敵編成の乱数
  def random_for_enemy(event_index, purpose:)
    source = "#{adventure.random_seed}:#{purpose}:#{event_index}"

    seed = Digest::SHA256.hexdigest(source).to_i(16) % (2**63)

    Random.new(seed)
  end

  # 全滅判定
  def adventure_wiped_out?
    adventure.adventure_members.reload.all? { |member| member.current_hp <= 0 }
  end
end
