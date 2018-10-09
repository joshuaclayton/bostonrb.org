class EventService
  def self.upcoming_events(group_name:, data_source: MeetupApi.new)
    new(group_name, data_source).upcoming_events
  end

  def initialize(group_name, data_source)
    @group_name = group_name
    @data_source = data_source
  end

  def upcoming_events
    response = fetch_upcoming_events

    if response.success?
      events = build_events(response.parsed_body)
      filter_upcoming_events(events)
    else
      []
    end
  end

  private
  attr_reader :group_name, :data_source

  def fetch_upcoming_events
    @_upcoming_events ||= data_source.upcoming_events(group_name)
  end

  def build_events(events_data)
    events_data.map do |event_data|
      EventParser.new(event_data).parse
    end
  end

  def filter_upcoming_events(events)
    events.select do |event|
      current_or_upcoming_date?(event)
    end
  end

  def current_or_upcoming_date?(event)
    event.starts_at.to_date >= DateTime.current.to_date
  end
end
