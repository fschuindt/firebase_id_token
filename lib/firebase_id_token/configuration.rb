module FirebaseIdToken
  # Handles the configuration object. Check out {FirebaseIdToken} for more
  # info on how to use it.
  LIB_PATH = File.expand_path('../../', __FILE__)

  class Configuration
    attr_accessor :redis, :project_ids, :certificates, :cache_store

    def initialize
      @project_ids = []
      @certificates = FirebaseIdToken::Certificates
      # support older API where redis attribute was explictly set
      if redis
        @cache_store = ActiveSupport::Cache.RedisStore.new(redis)
      end
    end
  end
end
