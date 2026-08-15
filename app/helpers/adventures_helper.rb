module AdventuresHelper
  def format_adventure_time(time)
    time.strftime("%m/%d %H:%M")
  end

  def format_adventure_clock(time)
    time.strftime("%H:%M")
  end

  # 冒険中と冒険前でURLを切り替える
  def adventure_navigation_path(user)
    adventure = user.incomplete_adventure
    adventure ? adventure_path(adventure) : new_adventure_path
  end
end
