module Cloudevents
  module V01
    class HTTPMarshaller
      def initialize(converters = [])
        @converters = Hash[converters.map do |converter|
                             [converter.type, converter]
                           end]
      end

      def self.default
        new([
          BinaryConverter.new,
          JSONConverter.new,
        ])
      end

      def from_request(request, &block)
        raise ArgumentError, "request can not be nil" if request.nil?

        converter = @converters.values.find do |converter|
          converter.can_read?(request.media_type)
        end

        if converter
          converter.read(Event.new, request, &block)
        else
          raise ContentTypeNotSupportedError
        end
      end
      def to_request(event, converter_type, &block)
        if converter = @converters[content_type]
          converter.write(event, &block)
        else
          raise NoSuchConverter
        end
      end
    end
  end
end
