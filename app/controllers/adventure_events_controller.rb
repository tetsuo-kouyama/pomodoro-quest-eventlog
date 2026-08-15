class AdventureEventsController < ApplicationController
  def index
    @adventure = current_user.adventures.find(params[:adventure_id])
    @adventure_events = @adventure.adventure_events.order(event_index: :desc)
  end
end
