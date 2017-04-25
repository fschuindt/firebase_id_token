module FirebaseIdToken
  module Exceptions
    # @see FirebaseIdToken::Certificates.request
    # @see FirebaseIdToken::Certificates.request_anyway
    class CertificatesRequestError < RuntimeError
      def initialize(code)
        super "#{code} HTTP status when requesting Google's certificates."
      end
    end
  end
end
