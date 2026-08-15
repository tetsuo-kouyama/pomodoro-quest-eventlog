class BattleSimulator
  MAX_TURNS = 100

  Combatant = Struct.new(
    :adventure_member_id,
    :name,
    :hp,
    :max_hp,
    :attack,
    :defense,
    :speed,
    :side,
    keyword_init: true
  )

  def initialize(adventure:, dungeon_enemy:, random:)
    @adventure = adventure
    @dungeon_enemy = dungeon_enemy
    @random = random
    @allies = build_allies
    @enemies = build_enemies
    @logs = []
    @turn = 1
  end

  # 戦闘全体の処理
  def call
    add_encounter_log

    until allies_defeated? || enemies_defeated? || @turn > MAX_TURNS
      process_turn
      @turn += 1
    end

    persist_ally_hp!

    build_result
  end

  private

  attr_reader :adventure, :dungeon_enemy, :random, :allies, :enemies, :logs

  # 1ターンの処理
  def process_turn
    action_order.each do |attacker|
      next unless alive?(attacker)

      target =
        if attacker.side == :ally
          choose_target(enemies)
        else
          choose_target(allies)
        end

      break unless target

      attack(attacker, target)

      break if allies_defeated? || enemies_defeated?
    end
  end

  # 生存判定
  def alive?(combatant)
    combatant.hp > 0
  end

  # 味方が全滅したかを判定する
  def allies_defeated?
    allies.none? { |ally| alive?(ally) }
  end

  # 敵が全滅したかを判定する
  def enemies_defeated?
    enemies.none? { |enemy| alive?(enemy) }
  end

  # ダメージ計算
  def calculate_damage(attacker, target)
    [ attacker.attack - target.defense, 1 ].max
  end

  # 攻撃対象を選ぶ
  def choose_target(candidates)
    candidates.select { |combatant| alive?(combatant) }.sample(random: random)
  end

  # 攻撃処理
  def attack(attacker, target)
    damage = calculate_damage(attacker, target)

    hp_before = target.hp
    target.hp = [ target.hp - damage, 0 ].max

    logs << {
      actor_type: attacker.side.to_s,
      message: "#{attacker.name}の攻撃！"
    }

    logs << {
      actor_type: attacker.side.to_s,
      message: "#{target.name}に#{damage}ダメージ！ HP #{hp_before} → #{target.hp}"
    }

    if target.hp.zero?
      logs << {
        actor_type: "system",
        message: "#{target.name}を倒した！"
      }
    end
  end

  # 行動順を決める
  def action_order
    (allies + enemies).select { |combatant| alive?(combatant) }
                      .sort_by { |combatant| -combatant.speed }
  end

  # 遭遇ログ
  def add_encounter_log
    logs << {
      actor_type: "system",
      message: "#{dungeon_enemy.monster.name}×#{dungeon_enemy.enemy_count}が現れた！"
    }
  end

  # 戦闘結果を返す
  def build_result
    victory = enemies_defeated?

    logs << {
      actor_type: "system",
      message: victory ? "戦闘に勝利した！" : "戦闘に敗北した..."
    }

    {
      victory: victory,
      logs: logs
    }
  end

  # 戦闘終了後に現在のHPを記録
  def persist_ally_hp!
    members_by_id = adventure.adventure_members.index_by(&:id)

    allies.each do |ally|
      member = members_by_id.fetch(ally.adventure_member_id)
      member.update!(current_hp: ally.hp)
    end
  end

  # 味方データの取得
  def build_allies
    adventure.adventure_members.map do |member|
      owned_monster = member.owned_monster

      Combatant.new(
        adventure_member_id: member.id,
        name: owned_monster.nickname,
        hp: member.current_hp,
        max_hp: member.max_hp,
        attack: owned_monster.attack,
        defense: owned_monster.defense,
        speed: owned_monster.speed,
        side: :ally
      )
    end
  end

  # 敵データの取得
  def build_enemies
    Array.new(dungeon_enemy.enemy_count) do |index|
      hp = dungeon_enemy.hp
      attack = dungeon_enemy.attack
      defense = dungeon_enemy.defense
      speed = dungeon_enemy.speed

      Combatant.new(
        name: "#{dungeon_enemy.monster.name}#{index + 1}",
        hp: hp,
        max_hp: hp,
        attack: attack,
        defense: defense,
        speed: speed,
        side: :enemy
      )
    end
  end
end
