module FirebaseIdToken
  module Exceptions
    # @see FirebaseIdToken::Certificates.request
    # @see FirebaseIdToken::Certificates.request!
    class UnsupportedCacheOperationError < StandardError
      def initialize(message = "Cache store does not support a TTL read on entries")
        super message
      end
    end
  end
end
