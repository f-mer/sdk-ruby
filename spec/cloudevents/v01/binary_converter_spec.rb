require "spec_helper"

describe Cloudevents::V01::BinaryConverter do
  describe "#read" do
    it "deserializes" do
      request = Rack::Request.new(Rack::MockRequest.env_for(
        "http://example.com/",
        "CONTENT_TYPE" => "application/json",
        "HTTP_CE_CLOUDEVENTSVERSION" => "1",
        "HTTP_CE_EVENTTYPE" => "com.example.someevent",
        "HTTP_CE_SOURCE" => "/mycontext",
        "HTTP_CE_EVENTID" => "1234-1234-1234",
        "HTTP_CE_EVENTTYPEVERSION" => "1.1",
        "HTTP_CE_EVENTTIME" => "2018-04-05T03:56:24Z",
        "HTTP_CE_SCHEMAURL" => "http://example.com/schema",
        input: "Hello CloudEvents!",
      ))

      event = Cloudevents::V01::Event.new
      converter = Cloudevents::V01::BinaryConverter.new
      event = converter.read(event, request) { |io| io.read }
      event.content_type.must_equal("application/json")
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

      converter = Cloudevents::V01::BinaryConverter.new
      headers, data = converter.write(event)

      headers["Content-Type"].must_equal("application/json")
      headers["CE-CloudEventsVersion"].must_equal("1")
      headers["CE-EventType"].must_equal("com.example.someevent")
      headers["CE-EventTypeVersion"].must_equal("1.1")
      headers["CE-Source"].must_equal("/mycontext")
      headers["CE-EventID"].must_equal("1234-1234-1234")
      headers["CE-EventTime"].must_equal("2018-04-05T03:56:24Z")
      headers["CE-SchemaUrl"].must_equal("http://example.com/schema")
      data.must_equal("Hello CloudEvents!")
    end
  end

  describe "#can_read?" do
    context "supported content type" do
      it "returns true" do
        converter = Cloudevents::V01::BinaryConverter.new

        converter.can_read?("application/json").must_equal(true)
        converter.can_read?("application/xml").must_equal(true)
        converter.can_read?("application/octet-stream").must_equal(true)
      end
    end

    context "unsupported content type" do
      it "returns false" do
        converter = Cloudevents::V01::BinaryConverter.new

        converter.can_read?("application/soap+xml").must_equal(false)
      end
    end
  end
end
