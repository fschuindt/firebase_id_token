require 'pry'
module FirebaseIdToken
  # Deals with verifying if a given Firebase ID Token is signed by one of the
  # Google's x509 certificates that Firebase uses.
  #
  # Also checks if the resulting JWT payload hash matches with:
  # + `exp` Expiration time
  # + `iat` Issued at time
  # + User's Firebase Project ID
  # + Non-empty UID
  #
  # ## Verifying a Firebase ID Token
  #
  # *Be sure to configure the gem to set your Firebase Project ID and a Redis
  # server before move any forward.*
  #
  # **See the README for a complete guide.**
  #
  # **WARNING:** Trying to verify a token without any certificate saved in
  # Redis certificates database raises a {Exceptions::NoCertificatesError}.
  #
  # @example
  #   FirebaseIdToken::Signature.verify(thrusty_token)
  #   => {"iss"=>"https://securetoken.google.com/your-project-id", [...]}
  #
  #   FirebaseIdToken::Signature.verify(fake_token)
  #   => nil
  #
  # @see Signature#verify
  class Signature
    # Pre-default JWT algorithm parameters as recommended
    # [here](https://goo.gl/uOK5Jx).
    JWT_DEFAULTS = { algorithm: 'RS256', verify_iat: true }

    # Returns the decoded JWT hash payload of the Firebase ID Token if the
    # signature in the token matches with one of the certificates downloaded
    # by {FirebaseIdToken::Certificates.request}, returns `nil` otherwise.
    #
    # It will also return `nil` when it fails in checking if all the required
    # JWT fields are valid, as recommended [here](https://goo.gl/yOrZZX) by
    # Firebase official documentation.
    #
    # Note that it will raise a {Exceptions::NoCertificatesError} if the Redis
    # certificates database is empty. Ensure to call {Certificates.request}
    # before, ideally in a background job if you are using Rails.
    # @return [nil, Hash]
    def self.verify(jwt_token)
      new(jwt_token).verify
    end

    attr_accessor :firebase_id_token_certificates

    # Loads attributes: `:project_ids` from {FirebaseIdToken::Configuration},
    # and `:kid`, `:jwt_token` from the related `jwt_token`.
    # @param [String] jwt_token Firebase ID Token
    def initialize(jwt_token)
      @project_ids = FirebaseIdToken.configuration.project_ids
      @kid = extract_kid(jwt_token)
      @jwt_token = jwt_token
      self.firebase_id_token_certificates = FirebaseIdToken.configuration.certificates

    end

    # @see Signature.verify
    def verify
      certificate = firebase_id_token_certificates.find(@kid)
      if certificate
        payload = decode_jwt_payload(@jwt_token, certificate.public_key)
        authorize payload
      end
    end

    private

    def extract_kid(jwt_token)
      JWT.decode(jwt_token, nil, false).last['kid']
    rescue StandardError
      'none'
    end

    def decode_jwt_payload(token, cert_key)
      JWT.decode(token, cert_key, true, JWT_DEFAULTS).first
    rescue StandardError
      nil
    end

    def authorize(payload)
      if payload && authorized?(payload)
        payload
      end
    end

    def authorized?(payload)
      still_valid?(payload) &&
      @project_ids.include?(payload['aud']) &&
      issuer_authorized?(payload) &&
      ! payload['sub'].empty?
    end

    def still_valid?(payload)
      payload['exp'].to_i > Time.now.to_i &&
      payload['iat'].to_i <= Time.now.to_i
    end

    def issuer_authorized?(payload)
      issuers = @project_ids.map { |i| "https://securetoken.google.com/#{i}" }
      issuers.include? payload['iss']
    end
  end
end
