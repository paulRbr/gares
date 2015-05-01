module Gares
  # All errors from this gem will inherit from this one.
  class Error < StandardError
  end
  class UnsupportedIndex < StandardError
  end

  # Raised when requesting a train that does not exist.
  class TrainNotFound < Error
  end
  # Raised when requesting a station that does not exist.
  class StationNotFound < Error
  end
end
