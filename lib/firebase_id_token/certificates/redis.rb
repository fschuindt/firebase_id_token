module FirebaseIdToken
  # Redis specific methods for Certificates class
  class Certificates::Redis < Certificates
    attr_reader :redis

    def initialize(source: :id_token)
      @source = source
      @redis = ::Redis::Namespace.new('firebase_id_token',
        redis: FirebaseIdToken.configuration.redis)
      @local_certs = read_certificates
    end

    # Returns the current certificates TTL (Time-To-Live) in seconds. *Zero
    # meaning no certificates.* It's the same as the certificates expiration
    # time, use it to know when to request again.
    # @return [Fixnum]
    def self.ttl(source: :id_token)
      ttl = new(source: source).redis.ttl(CACHE_KEYS.fetch(source))
      ttl < 0 ? 0 : ttl
    end

    private

    def read_certificates
      certs = @redis.get cache_key
      certs ? JSON.parse(certs) : {}
    end

    def save_certificates
      @redis.setex cache_key, ttl, @request.body
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

