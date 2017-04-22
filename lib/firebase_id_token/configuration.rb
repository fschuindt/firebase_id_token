module FirebaseIdToken
  class Configuration
    attr_accessor :redis, :project_ids

    def initialize
      @redis = Redis.new
      @project_ids = []
    end
  end
end
