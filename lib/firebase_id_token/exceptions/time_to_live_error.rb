module FirebaseIdToken
  module Exceptions
    class TimeToLiveError < SecurityError
      def initialize(message = "Google's x509 certificates has a low TTL.")
        super message
      end
    end
  end
end
