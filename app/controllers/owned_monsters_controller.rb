class OwnedMonstersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  before_action :set_owned_monster, only: %i[ show destroy levelup ]
  before_action :ensure_not_locked, only: %i[ destroy levelup ]


  def index
    @owned_monsters = current_user.owned_monsters.includes(:monster)
  end

  def new
    @owned_monster = OwnedMonster.new

    # 解放済みのモンスターを取得
    set_unlocked_monsters
  end

  def create
    @monster = Monster.find(owned_monster_params[:monster_id])
    @owned_monster = current_user.owned_monsters.build(owned_monster_params)

    current_user.hire_monster!(@owned_monster, @monster)

    redirect_to owned_monsters_path, notice: "#{@owned_monster.nickname}を雇用しました！"

  rescue MonsterLockedError
    reload_form_on_failure("このモンスターはまだ解放されていません")
  rescue InsufficientGoldError
    reload_form_on_failure("ゴールドが足りません(必要: #{@monster.hire_cost}G / 所持: #{current_user.gold}G)")
  rescue ActiveRecord::RecordInvalid
    # DBの最新状態を再取得することで、エラー時にgoldが減っているように見える問題を解決
    current_user.reload
    reload_form_on_failure("雇用できませんでした")
  end

  def show; end

  def destroy
    if @owned_monster.destroy
      redirect_to owned_monsters_path, notice: "モンスターを解雇しました", status: :see_other
    else
      # before_destroy で弾かれた場合の処理
      redirect_to owned_monster_path(@owned_monster), alert: @owned_monster.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def levelup
    @owned_monster.increment_level!(current_user)
    redirect_to owned_monster_path(@owned_monster), notice: "レベルアップしました！"

  rescue InsufficientGoldError
    redirect_to owned_monster_path(@owned_monster), alert: "ゴールドが足りません(必要: #{@owned_monster.next_level_cost}G / 所持: #{current_user.gold}G)"
  rescue LevelMaxReachedError
    redirect_to @owned_monster, alert: "これ以上レベルを上げられません"
  end


  private

  def owned_monster_params
    params.require(:owned_monster).permit(:nickname, :monster_id)
  end

  def reload_form_on_failure(message = nil)
    flash.now[:alert] = message if message
    set_unlocked_monsters
    render :new, status: :unprocessable_entity
  end

  def set_owned_monster
    @owned_monster = current_user.owned_monsters.find(params[:id])
  end

  # 解放済みモンスターを取得する
  def set_unlocked_monsters
    @monsters = Monster.select { |monster| current_user.monster_unlocked?(monster) }
  end

  def ensure_not_locked
    return unless @owned_monster.locked_for_adventure?
    redirect_to owned_monster_path(@owned_monster), alert: "冒険中のモンスターは操作できません"
  end

  def handle_not_found
    redirect_to owned_monsters_path, alert: "指定されたモンスターは見つかりませんでした", status: :see_other
  end
end
