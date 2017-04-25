module FirebaseIdToken
  module Exceptions
    module Certificates
      class NoEntitiesError < RuntimeError
        def initialize(message = "There's no certificates in Redis database.")
          super message
        end
      end
    end
  end
end
