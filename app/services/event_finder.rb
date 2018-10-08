class EventFinder
  def self.next_event(group_name)
    events = EventService.upcoming_events(group_name: group_name)

    if events.present?
      events.first
    else
      MissingEvent.new
    end
  end
end
