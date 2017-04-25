module FirebaseIdToken
  module Exceptions
    # @see FirebaseIdToken::Certificates.find
    class NoCertificatesError < RuntimeError
      def initialize(message = "There's no certificates in Redis database.")
        super message
      end
    end
  end
end
