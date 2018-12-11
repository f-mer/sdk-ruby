module Cloudevents
  module V01
    class HTTPMarshaller
      def initialize(converters = {})
        @converters = converters
      end

      def self.converters
        @converters ||= {}
      end

      def self.register_converter(type, klass)
        raise ArgumentError, "converter with type `#{type}` is already registered" if converters.key?(type)

        converters[type] = klass
        nil
      end

      def self.default
        new(converters.reduce({}) do |memo, (type, klass)|
          memo[type] = klass.new
          memo
        end)
      end

      register_converter :binary, BinaryConverter
      register_converter :structured, JSONConverter

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
        raise ArgumentError, "event can not be nil" if event.nil?
        raise ArgumentError, "converter_type can not be nil" if converter_type.nil?

        if converter = @converters[converter_type]
          converter.write(event, &block)
        else
          raise NoSuchConverter
        end
      end
    end
  end
end
