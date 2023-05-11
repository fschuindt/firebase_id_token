module FirebaseIdToken
  # Handles the configuration object. Check out {FirebaseIdToken} for more
  # info on how to use it.
  LIB_PATH = File.expand_path('../../', __FILE__)

  class Configuration
    attr_accessor :redis, :project_ids, :certificates

    def initialize
      @project_ids = []
      @certificates = FirebaseIdToken::Certificates
    end
  end
end
