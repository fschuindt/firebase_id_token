module FirebaseIdToken
  # Manage download and access of Google's x509 certificates. Keeps
  # certificates on a Redis namespace database.
  #
  # ## Download & Access Certificates
  #
  # It describes two ways to download it: {.request} and {.request_anyway}.
  # The first will only do something when Redis certificates database is empty,
  # the second one will always request a new download to Google's API and
  # override the database with the response.
  #
  # It's important to note that when saving a set of certificates, it will also
  # set a Redis expiration time to match Google's API header `expires`. **After
  # this time went out, Redis will automatically delete those certificates.**
  #
  # When comes to accessing it, you can either use {.present?} to check if
  # there's any data inside Redis certificates database or {.all} to obtain a
  # `Array` of current certificates.
  #
  # @example `.request` will only download once
  #   FirebaseIdToken::Certificates.request # Downloads certificates.
  #   FirebaseIdToken::Certificates.request # Won't do anything.
  #   FirebaseIdToken::Certificates.request # Won't do anything either.
  #
  # @example `.request_anyway` will download always
  #   FirebaseIdToken::Certificates.request # Downloads certificates.
  #   FirebaseIdToken::Certificates.request_anyway # Downloads certificates.
  #   FirebaseIdToken::Certificates.request_anyway # Downloads certificates.
  #
  # @see Certificates.present?
  # @see Certificates.all
  #
  class Certificates
    # Certificates in Redis (JSON `String` or `nil`).
    attr_reader :local_certs

    # Google's x509 certificates API URL.
    URL = 'https://www.googleapis.com/robot/v1/metadata/x509/'\
      'securetoken@system.gserviceaccount.com'

    # It is really a alias for the instance method {#request}, but you should
    # use it in your application as it is more convenient.
    #
    # To see how it works, check the {#request} instance method documentation.
    # @return [Hash, nil, Exceptions::Certificates::RequestCodeError]
    # @see Certificates#request
    def self.request
      new.request
    end

    # It is really a alias for the instance method {#request_anyway}, but you
    # should use it in your application as it is more convenient.
    #
    # To see how it works, check the {#request_anyway} instance method
    # documentation.
    # @return [Hash, Exceptions::Certificates::RequestCodeError]
    # @see Certificates#request_anyway
    def self.request_anyway
      new.request_anyway
    end

    # Returns `true` if there's certificates data on Redis, `false` otherwise.
    # @example
    #   FirebaseIdToken::Certificates.present? #=> false
    #   FirebaseIdToken::Certificates.request
    #   FirebaseIdToken::Certificates.present? #=> true
    def self.present?
      ! new.local_certs.empty?
    end

    # Returns a array of hashes, each hash is a single `{key => value}` pair
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

    # Sets two instance attributes: `:redis` and `:local_certs`. Those are
    # respectively a Redis instance from {FirebaseIdToken::Configuration} and
    # the certificates in it.
    def initialize
      @redis = Redis::Namespace.new('firebase_id_token',
        redis: FirebaseIdToken.configuration.redis)
      @local_certs = read_certificates
    end

    # Calls {#request_anyway} only if there's no certificates on Redis. It will
    # return `nil` otherwise.
    #
    # You should refer to the class method {.request} for using it in your
    # application.
    # @return [Hash, nil, Exceptions::Certificates::RequestCodeError]
    # @see Certificates#request_anyway
    def request
      request_anyway if @local_certs.empty?
    end

    # Triggers a HTTPS request to Google's x509 certificates API. If it
    # responds with a status `200 OK`, saves the request body into Redis and
    # returns it as a `Hash`. Otherwise it will raise a
    # {Exceptions::Certificates::RequestCodeError}.
    #
    # You should refer to the class method {.request_anyway} for using it in
    # your application.
    # @return [Hash, Exceptions::Certificates::RequestCodeError]
    def request_anyway
      @request = HTTParty.get URL
      code = @request.code
      if code == 200
        save_certificates
      else
        raise Exceptions::Certificates::RequestCodeError.new(code)
      end
    end

    private

    def read_certificates
      certs = @redis.get 'certificates'
      certs ? JSON.parse(certs) : {}
    end

    def save_certificates
      @redis.setex 'certificates', ttl, @request.body
      @local_certs = read_certificates
    end

    def ttl
      ttl = DateTime.parse(@request.headers['expires']).
        to_time.to_i - Time.now.to_i

      if ttl > 3600
        ttl
      else
        raise Exceptions::Certificates::TimeToLiveError
      end
    end
  end
end
