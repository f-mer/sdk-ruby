module Cloudevents
  module V01
    class HTTPMarshaller
      # @param converters [Array(BinaryConverter|JSONConverter)]
      # @return [HTTPMarshaller]
      def initialize(converters = {})
        @converters = converters
      end

      # @return [Array<Converter>]
      def self.converters
        @converters ||= {}
      end

      # @param type [Symbol]
      # @param klass [Converter]
      def self.register_converter(type, klass)
        raise ArgumentError, "converter with type `#{type}` is already registered" if converters.key?(type)

        converters[type] = klass
        nil
      end

      # @return [HTTPMarshaller]
      def self.default
        new(converters.reduce({}) do |memo, (type, klass)|
          memo[type] = klass.new
          memo
        end)
      end

      register_converter :binary, BinaryConverter
      register_converter :structured, JSONConverter

      # @param request [Rack::Request]
      # @yieldparam io [IO]
      # @yieldreturn unserialized data
      # @return [Event]
      def from_request(request, &block)
        raise ArgumentError, "request can not be nil" if request.nil?

        converter = @converters.values.find do |converter|
          converter.can_read?(request.media_type)
        end

        if converter
          converter.read(Event.new, request, &block)
        else
          raise ContentTypeNotSupportedError, "Content-Type `#{request.media_type}` is not supported"
        end
      end

      # @param event [Event]
      # @param converter_type [:binary,:structured]
      # @yieldparam data
      # @yieldreturn serialized data
      # @return [Array(Hash{String => String}, String)] headers and data
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
