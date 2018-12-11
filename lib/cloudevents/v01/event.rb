module Cloudevents
  module V01
    # @attr cloud_events_version [String] is a mandatory property
    # @attr event_type [String] is a mandatory property
    # @attr event_type_version [String] is a mandatory property
    # @attr source [String] is a mandatory property
    # @attr event_id [String] is an optional property
    # @attr event_time [String] is a optional property
    # @attr schema_url [String] is a optional property
    # @attr content_type [String] is a optional property
    # @attr data is a optional property
    class Event
      attr_accessor :cloud_events_version,
                    :event_type,
                    :event_type_version,
                    :source,
                    :event_id,
                    :event_time,
                    :schema_url,
                    :content_type,
                    :data
    end
  end
end
