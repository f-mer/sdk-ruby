module Cloudevents
  module V01
    class BinaryConverter
      SUPPORTED_MEDIA_TYPES = [
        "application/json",
        "application/xml",
        "application/octet-stream",
      ]

      def type
        :binary
      end
      def read(event, request, &block)
        event.cloud_events_version = request.fetch_header("HTTP_CE_CLOUDEVENTSVERSION")
        event.event_type = request.fetch_header("HTTP_CE_EVENTTYPE")
        event.event_type_version = request.fetch_header("HTTP_CE_EVENTTYPEVERSION") { nil }
        event.source = request.fetch_header("HTTP_CE_SOURCE")
        event.event_id = request.fetch_header("HTTP_CE_EVENTID")
        event.event_time = request.fetch_header("HTTP_CE_EVENTTIME") { nil }
        event.schema_url = request.fetch_header("HTTP_CE_SCHEMAURL") { nil }
        event.content_type = request.content_type
        event.data = yield request.body
        event
      end

      def write(event)
        headers = {
          "CE-CloudEventsVersion" => event.cloud_events_version,
          "CE-EventType" => event.event_type,
          "CE-EventTypeVersion" => event.event_type_version,
          "CE-Source" => event.source,
          "CE-EventID" => event.event_id,
          "CE-EventTime" => event.event_time,
          "CE-SchemaUrl" => event.schema_url,
        }

        [headers, event.data]
      end

      def can_read?(media_type)
        SUPPORTED_MEDIA_TYPES.include?(media_type)
      end
    end
  end
end
