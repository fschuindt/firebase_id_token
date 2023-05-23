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
      entry = cache_store.read('certificates')
      if entry.nil?
        lock do
          request!
        end
        entry = cache_store.read('certificates')
      end
      certs = {}
      certs = JSON.parse(JSON.parse(entry)["data"]) if entry
      certs
    rescue StandardError => e
      return {}
    end

    # we can't use ActiveSupport's fetch, because we need to set the expiration time of
    # the key based on a value we read from the request. This is a rudimentary mutex instead
    def lock
      acquire_lock
      yield
    ensure
      release_lock
    end

    def acquire_lock
      maybe_sleep
      cache_store.write('certificate_lock', expires_in: 5.seconds)
    end

    def maybe_sleep
      iteration = 0
      while cache_store.exist?('certificate_lock')
        iteration += 1
        sleep 1
        break if iteration > 5
      end
    end

    def release_lock
      cache_store.delete('certificate_lock')
    end

    def save_certificates
      expires_at = Time.now.to_i + ttl
      # set the expiration of the key to the certification expiration - RACE_CONDITION_TIME, so that the entry
      # will be expired before the certificate is
      cache_store.write 'certificates', { data: @request.body, expires_at: expires_at }.to_json,
        expires_in: (ttl - RACE_CONDITION_TIME)
      @local_certs = @request.body
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

