module FirebaseIdToken
  # Manage download and access of Google's x509 certificates. Keeps
  # certificates on a Redis namespace database.
  #
  # ## Download & Access Certificates
  #
  # It describes two ways to download it: {.request} and {.request!}.
  # The first will only do something when Redis certificates database is empty,
  # the second one will always request a new download to Google's API and
  # override the database with the response.
  #
  # It's important to note that when saving a set of certificates, it will also
  # set a Redis expiration time to match Google's API header `expires`. **After
  # this time went out, Redis will automatically delete those certificates.**
  #
  # *To know how many seconds left until the expiration you can use {.ttl}.*
  #
  # When comes to accessing it, you can either use {.present?} to check if
  # there's any data inside Redis certificates database or {.all} to obtain an
  # `Array` of current certificates.
  #
  # @example `.request` will only download once
  #   FirebaseIdToken::Certificates.request # Downloads certificates.
  #   FirebaseIdToken::Certificates.request # Won't do anything.
  #   FirebaseIdToken::Certificates.request # Won't do anything either.
  #
  # @example `.request!` will download always
  #   FirebaseIdToken::Certificates.request # Downloads certificates.
  #   FirebaseIdToken::Certificates.request! # Downloads certificates.
  #   FirebaseIdToken::Certificates.request! # Downloads certificates.
  #
  class Certificates
    # A common cache store
    attr_reader :cache_store
    # Certificates saved in the Redis (JSON `String` or `nil`).
    attr_reader :local_certs

    # Google's x509 certificates API URL.
    URL = 'https://www.googleapis.com/robot/v1/metadata/x509/'\
      'securetoken@system.gserviceaccount.com'

    # Calls {.request!} only if there are no certificates on Redis. It will
    # return `nil` otherwise.
    #
    # It will raise {Exceptions::CertificatesRequestError} if the request
    # fails or {Exceptions::CertificatesTtlError} when Google responds with a
    # low TTL, check out {.request!} for more info.
    #
    # @return [nil, Hash]
    # @see Certificates.request!
    def self.request
      new.request
    end

    # Triggers a HTTPS request to Google's x509 certificates API. If it
    # responds with a status `200 OK`, saves the request body into Redis and
    # returns it as a `Hash`.
    #
    # Otherwise it will raise a {Exceptions::CertificatesRequestError}.
    #
    # This is really rare to happen, but Google may respond with a low TTL
    # certificate. This is a `SecurityError` and will raise a
    # {Exceptions::CertificatesTtlError}. You are mostly like to never face it.
    # @return [Hash]
    def self.request!
      new.request!
    end

    # @deprecated Use only `request!` in favor of Ruby conventions.
    # It will raise a warning. Kept for compatibility.
    # @see Certificates.request!
    def self.request_anyway
      warn 'WARNING: FirebaseIdToken::Certificates.request_anyway is '\
        'deprecated. Use FirebaseIdToken::Certificates.request! instead.'

      new.request!
    end

    # Returns `true` if there's certificates data on Redis, `false` otherwise.
    # @example
    #   FirebaseIdToken::Certificates.present? #=> false
    #   FirebaseIdToken::Certificates.request
    #   FirebaseIdToken::Certificates.present? #=> true
    def self.present?
      ! new.local_certs.empty?
    end

    # Returns an array of hashes, each hash is a single `{key => value}` pair
    # containing the certificate KID `String` as key and a
    # `OpenSSL::X509::Certificate` object of the respective certificate as
    # value. Returns a empty `Array` when there's no certificates data on
    # Redis.
    # @return [Array]
    # @example
    #   FirebaseIdToken::Certificates.request
    #   certs = FirebaseIdToken::Certificates.all
    #   certs.first #=> {"1d6d01c7[...]" => #<OpenSSL::X509::Certificate[...]}
    def self.all
      new.local_certs.map { |kid, cert|
        { kid => OpenSSL::X509::Certificate.new(cert) } }
    end

    # Returns a `OpenSSL::X509::Certificate` object of the requested Key ID
    # (KID) if there's one. Returns `nil` otherwise.
    #
    # It will raise a {Exceptions::NoCertificatesError} if the Redis
    # certificates database is empty.
    # @param [String] kid Key ID
    # @return [nil, OpenSSL::X509::Certificate]
    # @example
    #   FirebaseIdToken::Certificates.request
    #   cert = FirebaseIdToken::Certificates.find "1d6d01f4w7d54c7[...]"
    #   #=> <OpenSSL::X509::Certificate: subject=#<OpenSSL [...]
    def self.find(kid, raise_error: false)
      certs = new.local_certs
      raise Exceptions::NoCertificatesError if certs.empty?

      return OpenSSL::X509::Certificate.new certs[kid] if certs[kid]

      return unless raise_error

      raise Exceptions::CertificateNotFound,
        "Unable to find a certificate with `#{kid}`."
    end

    # Returns a `OpenSSL::X509::Certificate` object of the requested Key ID
    # (KID) if there's one.
    #
    # @raise {Exceptions::CertificateNotFound} if it cannot be found.
    #
    # @raise {Exceptions::NoCertificatesError} if the Redis certificates
    # database is empty.
    #
    # @param [String] kid Key ID
    # @return [OpenSSL::X509::Certificate]
    # @example
    #   FirebaseIdToken::Certificates.request
    #   cert = FirebaseIdToken::Certificates.find! "1d6d01f4w7d54c7[...]"
    #   #=> <OpenSSL::X509::Certificate: subject=#<OpenSSL [...]
    def self.find!(kid)
      find(kid, raise_error: true)
    end

    # Returns the current certificates TTL (Time-To-Live) in seconds. *Zero
    # meaning no certificates.* It's the same as the certificates expiration
    # time, use it to know when to request again.
    # @return [Fixnum]
    def self.ttl
      if new.cache_store.respond_to?(:redis)
        ttl = new.cache_store.redis.ttl('certificates')
        return ttl < 0 ? 0 : ttl
      end
      # Not all cache stores supported by ActiveSupport::Cache support a TTL
      # read on an entrye
      raise Exceptions::UnsupportedCacheOperationError.new
    end

    # Sets two instance attributes: `:redis` and `:local_certs`. Those are
    # respectively a Redis instance from {FirebaseIdToken::Configuration} and
    # the certificates in it.
    def initialize
      @cache_store = FirebaseIdToken.configuration.cache_store
      @local_certs = read_certificates
    end

    # @see Certificates.request
    def request
      request! if @local_certs.empty?
    end

    # @see Certificates.request!
    def request!
      @request = HTTParty.get URL
      code = @request.code
      if code == 200
        save_certificates
      else
        raise Exceptions::CertificatesRequestError.new(code)
      end
    end

    private

    def read_certificates
      certs = @cache_store.read 'certificates'
      certs ? JSON.parse(certs) : {}
    end

    def save_certificates
      @cache_store.write 'certificates', @request.body, expires_in: ttl
      @local_certs = read_certificates
    end

    def ttl
      cache_control = @request.headers['cache-control']
      ttl = cache_control.match(/max-age=([0-9]+)/).captures.first.to_i

      if ttl > 3600
        ttl
      else
        raise Exceptions::CertificatesTtlError
      end
    end
  end
end
