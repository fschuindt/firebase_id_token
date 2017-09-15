module FirebaseIdToken
  module Exceptions
    # @see FirebaseIdToken::Certificates.request
    # @see FirebaseIdToken::Certificates.request!
    class CertificatesRequestError < StandardError
      def initialize(code)
        super "#{code} HTTP status when requesting Google's certificates."
      end
    end
  end
end
