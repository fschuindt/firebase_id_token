module FirebaseIdToken
  # Handles the configuration object. Check out {FirebaseIdToken} for more
  # info on how to use it.
  LIB_PATH = File.expand_path('../../', __FILE__)

  class Configuration
    attr_accessor :redis, :project_ids, :cache_store

    def initialize
      @project_ids = []
    end

    def certificates
      klass
    end

    def certificates=(value)
      @certificates = klass
    end

    def klass
      redis ? FirebaseIdToken::Certificates::Redis : FirebaseIdToken::Certificates::ActiveSupport
    end
  end
end
