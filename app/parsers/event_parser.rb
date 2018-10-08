class EventParser
  MissingMeetupDate = Class.new(StandardError)

  def initialize(data)
    @data = ActiveSupport::HashWithIndifferentAccess.new(data)
  end

  def parse
    Event.new(
      address: venue[:address_1],
      city: venue[:city],
      ends_at: end_time_utc,
      group_name: data[:group][:urlname],
      name: data[:name],
      starts_at: start_time_utc,
      state: venue[:state],
      url: data[:link],
      venue_name: venue[:name],
    )
  end

  private
  attr_reader :data

  def venue
    data.fetch(:venue)
  end

  def start_time_utc
    timestamp = data[:time]

    if timestamp.present?
      Time.at(timestamp/1000).utc
    else
      raise MissingMeetupDate
    end
  end

  def end_time_utc
    if duration.present?
      num_of_hours = duration_in_hours(duration).hours
      start_time_utc + num_of_hours
    end
  end

  def duration
    data[:duration]
  end

  def duration_in_hours(duration)
    duration/1000/60/60
  end
end
