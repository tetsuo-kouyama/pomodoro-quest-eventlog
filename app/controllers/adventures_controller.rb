class AdventuresController < ApplicationController
  before_action :redirect_if_incomplete_adventure_exists, only: %i[new create]
  before_action :set_adventure, only: %i[show events]
  before_action :generate_adventure_events, only: %i[show events]
  before_action :ensure_current_adventure, only: :show

  def index
    @adventures = current_user.adventures.includes(:dungeon).order(created_at: :desc).limit(20)
  end

  def new
    @adventure = Adventure.new
    @active_monsters = current_user.owned_monsters.active.order(:party_position)

    # 開放済みのダンジョンを取得
    @dungeons = Dungeon.order(:difficulty).select { |dungeon| current_user.dungeon_unlocked?(dungeon) }
  end

  def create
    active_monsters = current_user.owned_monsters.active.order(:party_position)

    if active_monsters.empty?
      redirect_to new_adventure_path, alert: "パーティを編成してください"
      return
    end

    @adventure = current_user.adventures.new(adventure_params)

    # 冒険に出発させるパーティメンバーと冒険データを紐付ける
    @adventure.assign_members(active_monsters)

    @adventure.prepare_for_departure!

    if @adventure.save
      redirect_to @adventure, notice: "冒険に出発しました!"
    else
      @active_monsters = active_monsters
      @dungeons = Dungeon.order(:difficulty)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @dungeon = @adventure.dungeon
    @adventure_members = @adventure.adventure_members.includes(owned_monster: :monster)
    @adventure_events = @adventure.adventure_events.order(event_index: :desc)
  end

  def claim
    ActiveRecord::Base.transaction do
      @adventure = current_user.adventures.lock.find(params[:id])

      unless @adventure.reward_claimable?
        redirect_to @adventure, alert: "報酬を受け取れません"
        return
      end

      final_reward = @adventure.final_reward_gold

      current_user.update!(gold: current_user.gold + final_reward)
      @adventure.update!(reward_claimed_at: Time.current)

      flash_message =
        if @adventure.victory?
          "🎉 冒険大成功！ #{final_reward}G を獲得しました！"
        elsif @adventure.wiped_out?
          "💀 冒険は失敗した… 命からがら #{final_reward}G を持ち帰った"
        end

      redirect_to new_adventure_path, notice: flash_message
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error e.message
    redirect_to @adventure, alert: "エラーが発生しました"
  end

  def events
    last_id = params[:last_event_id].to_i

    @new_events = @adventure.adventure_events.where("id > ?", last_id).order(event_index: :asc)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @adventure }
    end
  end

  private

  def adventure_params
    params.require(:adventure).permit(:dungeon_id, :required_time)
  end

  # 冒険中または報酬未取得の場合に冒険作成画面へのアクセスを防ぐ
  def redirect_if_incomplete_adventure_exists
    current_adventure = current_user.adventures.incomplete.order(start_at: :desc).first

    return unless current_adventure

    redirect_to adventure_path(current_adventure), alert: "進行中または報酬を受け取っていない冒険があります"
  end

  # 冒険を取得する
  def set_adventure
    @adventure = current_user.adventures.find(params[:id])
  end

  # 現在時刻までのイベントを生成し、冒険の最新状態を取得する
  def generate_adventure_events
    AdventureEventGenerator.new(@adventure).call
    # イベント生成中にstatusが変わる可能性があるため、最新状態を取得する
    @adventure.reload
  end

  # 古い冒険にアクセスした場合に、最新の冒険または作成画面へリダイレクト
  def ensure_current_adventure
    current_adventure = current_user.incomplete_adventure
    return if current_adventure == @adventure

    if current_adventure
      redirect_to current_adventure
    else
      redirect_to new_adventure_path
    end
  end
end
