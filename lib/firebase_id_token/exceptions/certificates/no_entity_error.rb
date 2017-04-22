module FirebaseIdToken
  module Exceptions
    module Certificates
      class NoEntityError < RuntimeError
        def initialize(message = "Redis 'certificates' database is empty.")
          super message
        end
      end
    end
  end
end
