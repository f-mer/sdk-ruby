module Cloudevents
  Error = Class.new(StandardError)
  ContentTypeNotSupportedError = Class.new(Error)
  NoSuchConverter = Class.new(Error)
end
