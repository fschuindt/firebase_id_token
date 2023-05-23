module FirebaseIdToken
  # ActiveSupport specific methods for Certificates class
  class Certificates::ActiveSupport < Certificates
    attr_reader :cache_store
    RACE_CONDITION_TIME = 5.seconds

    def initialize
      @cache_store = ::FirebaseIdToken.configuration.cache_store
      @local_certs = read_certificates
    end

    def self.ttl
      current_time = Time.now.to_i
      entry = new.cache_store.read 'certificates'
      if entry
        expires_at = JSON.parse(entry)["expires_at"]
        return expires_at - current_time < 0 ? 0 : expires_at - current_time
      end
      return 0
    end

    private

    def read_certificates
      entry = cache_store.fetch('certificates', race_condition_ttl: RACE_CONDITION_TIME) do
        request
      end
      certs = {}
      certs = JSON.parse(JSON.parse(entry)["data"]) if entry
      certs
    rescue StandardError
      return {}
    end

    def save_certificates
      expires_at = Time.now.to_i + ttl
      # set the expiration of the key to the certification expiration - RACE_CONDITION_TIME, so that the entry
      # will be expired before the certificate is
      cache_store.write 'certificates', { data: @request.body, expires_at: expires_at }.to_json,
        expires_in: (ttl - RACE_CONDITION_TIME)
      @local_certs = read_certificates
    end

    def ttl
      cache_control = @request.headers['cache-control']
      ttl = cache_control.match(/max-age=([0-9]+)/).captures.first.to_i

      if ttl > 3600
        ttl
      else
        raise ::FirebaseIdToken::Exceptions::CertificatesTtlError
      end
    end
  end
end

