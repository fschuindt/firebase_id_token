module FirebaseIdToken
  module Exceptions
    # @see FirebaseIdToken::Certificates.request
    # @see FirebaseIdToken::Certificates.request!
    class CertificatesTtlError < StandardError
      def initialize(message = "Google's x509 certificates has a low TTL.")
        super message
      end
    end
  end
end
