class HomesController < ApplicationController
  def show
    @upcoming_event = EventPresenter.new(upcoming_event)
  end

  private

  def upcoming_event
    EventFinder.next_event("bostonrb")
  end
end
