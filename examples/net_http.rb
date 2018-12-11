$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "net/http"
require "cloudevents"

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

marshaller = Cloudevents::V01::HTTPMarshaller.default
headers, body = marshaller.to_request(event, :binary) { |data| data }

http = Net::HTTP.new("localhost", 4567)
response = http.post2("/", body, headers)
