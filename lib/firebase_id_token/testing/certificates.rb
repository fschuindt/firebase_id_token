require 'pry'
module FirebaseIdToken
  module Testing
    class Certificates < FirebaseIdToken::Certificates
      def self.find(kid)
        cert = jwt_json['certificate']
        OpenSSL::X509::Certificate.new cert
      end

      private

      def self.jwt_json
        @certs ||= JSON.parse read_jwt_file
      end

      def self.read_jwt_file
        File.read('spec/fixtures/files/jwt.json')
      end
    end
  end
end
