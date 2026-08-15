module StatCalculatable
  extend ActiveSupport::Concern

  private

  def calculate_stat(base, level, growth)
    base + (level - 1) * growth
  end
end
