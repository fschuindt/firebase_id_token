module FirebaseIdToken
  # Handles the configuration object. Check out {FirebaseIdToken} for more
  # info on how to use it.
  class Configuration
    attr_accessor :redis, :project_ids

    def initialize
      @redis = Redis.new
      @project_ids = []
    end
  end
end
