module ReturningError
  class Unauthorized < StandardError; end
  class DeviceNotFound < StandardError; end
end