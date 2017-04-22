module FirebaseIdToken
  module Exceptions
    module Certificates
      class TimeToLiveError < SecurityError
        def initialize(message = "Google's x509 certificates has a low TTL.")
          super message
        end
      end
    end
  end
end
