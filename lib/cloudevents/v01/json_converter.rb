module Cloudevents
  module V01
    class JSONConverter
      # media types that can be read by this converter
      SUPPORTED_MEDIA_TYPES = [
        "application/cloudevents+json",
      ]

      # @param event [Event]
      # @param request [Rack::Request]
      # @yieldparam io [#read]
      # @yieldreturn serialized data
      # @return [Event]
      def read(event, request, &block)
        json = JSON.parse(request.body.read)
        event.cloud_events_version = json["cloudEventsVersion"]
        event.event_type = json["eventType"]
        event.event_type_version = json["eventTypeVersion"]
        event.source = json["source"]
        event.event_id = json["eventID"]
        event.event_time = json["eventTime"]
        event.schema_url = json["schemaUrl"]
        event.content_type = request.content_type
        event.data = yield StringIO.new(json["data"])
        event
      end

      # @param event [Event]
      # @yieldparam data
      # @yieldreturn serialized data
      # @return [Array(Hash{String => String}, #read)]
      def write(event, &block)
        headers = {
          "Content-Type" => "application/cloudevents+json",
        }
        data = {
          cloudEventsVersion: event.cloud_events_version,
          eventType: event.event_type,
          eventTypeVersion: event.event_type_version,
          source: event.source,
          eventID: event.event_id,
          eventTime: event.event_time,
          schemaUrl: event.schema_url,
          data: (yield event.data),
        }

        [headers, data.to_json]
      end

      # @param media_type [String]
      # @return [Boolean]
      def can_read?(media_type)
        SUPPORTED_MEDIA_TYPES.include?(media_type)
      end
    end
  end
end
