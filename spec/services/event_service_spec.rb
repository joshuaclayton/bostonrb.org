RSpec.describe EventService do
  describe "#upcoming_events" do
    it "returns upcoming events for the given meetup group" do
      group_name = "my-awesome-group"
      meetup_event = future_meetup_event(group_name)
      fake_meetup_api = FakeMeetupApi.new(events: [meetup_event])

      events = EventService.upcoming_events(
        group_name: "my-awesome-group",
        data_source: fake_meetup_api
      )

      expect(events.first.name).to eq(meetup_event["name"])
    end

    context "when the API inaccurately returns past events" do
      it "ignores events from previous days" do
        group_name = "my-awesome-group"
        future_meetup_event = future_meetup_event(group_name)
        past_meetup_event = past_meetup_event(group_name)

        fake_meetup_api = FakeMeetupApi.new(
          events: [past_meetup_event, future_meetup_event]
        )

        events = EventService.upcoming_events(
          group_name: "my-awesome-group",
          data_source: fake_meetup_api
        )

        expect(events.count).to eq(1)
        expect(events.first.name).to eq(future_meetup_event["name"])
      end
    end

    context "when the request fails" do
      it "returns an empty collection" do
        fake_meetup_api = FakeMeetupApi.new(events: [], success: false)

        events = EventService.upcoming_events(
          group_name: "invalid-group",
          data_source: fake_meetup_api
        )

        expect(events).to be_empty
      end
    end
  end

  def future_meetup_event(group_name)
    future_time_ms = 2.days.from_now.to_i * 1000

    event_data.deep_merge(
      "time" => future_time_ms,
      "group" => { "urlname" => group_name }
    )
  end

  def past_meetup_event(group_name)
    past_time_ms = 2.days.ago.to_i * 1000

    event_data.deep_merge(
      "time" => past_time_ms,
      "group" => { "urlname" => group_name }
    )
  end

  def event_data
    JSON.parse(
      File.read(Rails.root.join("spec/fixtures/meetup_event.json"))
    )
  end
end
