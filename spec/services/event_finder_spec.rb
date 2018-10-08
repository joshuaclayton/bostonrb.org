RSpec.describe EventFinder do
  describe ".next_event" do
    it "returns the first upcoming event" do
      group_name = "lightening-talks"

      events = build_events(group_name)

      allow(EventService)
        .to receive(:upcoming_events)
        .with(group_name: group_name)
        .and_return(events)

      event = EventFinder.next_event(group_name)

      expect(event.name).to eq(events.first.name)
    end

    context "when there are no upcoming events" do
      it "returns an unknown event" do
        group_name = "lightening-talks"

        allow(EventService)
          .to receive(:upcoming_events)
          .with(group_name: group_name)
          .and_return([])

        event = EventFinder.next_event(group_name)

        expect(event).to be_an_instance_of(MissingEvent)
      end
    end
  end

  def build_events(group_name)
    [
      EventParser.new(event_data).parse,
      EventParser.new(event_data).parse,
    ]
  end

  def event_data
    JSON.parse(
      File.read(Rails.root.join("spec/fixtures/meetup_event.json"))
    )
  end
end
