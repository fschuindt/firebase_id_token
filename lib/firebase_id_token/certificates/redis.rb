module FirebaseIdToken
  # Redis specific methods for Certificates class
  class Certificates::Redis < Certificates
    attr_reader :redis

    def initialize
      @redis = ::Redis::Namespace.new('firebase_id_token',
        redis: FirebaseIdToken.configuration.redis)
      @local_certs = read_certificates
    end

    # Returns the current certificates TTL (Time-To-Live) in seconds. *Zero
    # meaning no certificates.* It's the same as the certificates expiration
    # time, use it to know when to request again.
    # @return [Fixnum]
    def self.ttl
      ttl = new.redis.ttl('certificates')
      ttl < 0 ? 0 : ttl
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

