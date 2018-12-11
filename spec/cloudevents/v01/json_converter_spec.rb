require "spec_helper"

describe Cloudevents::V01::BinaryConverter do
  describe "#read" do
    it "deserializes" do
      payload = <<-JSON
              {
                "cloudEventsVersion": "1",
                "eventType": "com.example.someevent",
                "source":  "/mycontext",
                "eventID": "1234-1234-1234",
                "eventTypeVersion": "1.1",
                "eventTime": "2018-04-05T03:56:24Z",
                "schemaUrl": "http://example.com/schema",
                "data": "Hello CloudEvents!"
              }
            JSON
      request = Rack::Request.new(Rack::MockRequest.env_for(
        "http://example.com/",
        "CONTENT_TYPE" => "application/cloudevents+json",
        input: payload,
      ))

      event = Cloudevents::V01::Event.new
      converter = Cloudevents::V01::JSONConverter.new
      event = converter.read(event, request) { |data| data.read }
      event.content_type.must_equal("application/cloudevents+json")
      event.cloud_events_version.must_equal("1")
      event.event_type.must_equal("com.example.someevent")
      event.source.must_equal("/mycontext")
      event.event_id.must_equal("1234-1234-1234")
      event.event_type_version.must_equal("1.1")
      event.event_time.must_equal("2018-04-05T03:56:24Z")
      event.schema_url.must_equal("http://example.com/schema")
      event.data.must_equal("Hello CloudEvents!")
    end
  end

  describe "#write" do
    it "serializes" do
      event = Cloudevents::V01::Event.new
      event.content_type = "application/json"
      event.cloud_events_version = "1"
      event.event_type = "com.example.someevent"
      event.source = "/mycontext"
      event.event_id = "1234-1234-1234"
      event.event_type_version = "1.1"
      event.event_time = "2018-04-05T03:56:24Z"
      event.schema_url = "http://example.com/schema"
      event.data = "Hello CloudEvents!"

      converter = Cloudevents::V01::JSONConverter.new
      headers, data = converter.write(event) { |data| data }

      headers["Content-Type"].must_equal("application/cloudevents+json")
      data.must_equal('{"cloudEventsVersion":"1","eventType":"com.example.someevent","eventTypeVersion":"1.1","source":"/mycontext","eventID":"1234-1234-1234","eventTime":"2018-04-05T03:56:24Z","schemaUrl":"http://example.com/schema","data":"Hello CloudEvents!"}')
    end
  end

  describe "#can_read?" do
    context "supported content type" do
      it "returns true" do
        converter = Cloudevents::V01::JSONConverter.new

        converter.can_read?("application/cloudevents+json").must_equal(true)
      end
    end

    context "unsupported content type" do
      it "returns false" do
        converter = Cloudevents::V01::JSONConverter.new

        converter.can_read?("application/soap+xml").must_equal(false)
      end
    end
  end
end
