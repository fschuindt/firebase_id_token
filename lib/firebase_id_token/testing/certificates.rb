module FirebaseIdToken
  module Testing
    class Certificates
      def self.find(kid)
        cert = certificate
        OpenSSL::X509::Certificate.new cert
      end

      def self.private_key
        @rsa_private ||= jwt_json['private_key']
      end

      def self.certificate
        @certs ||= jwt_json['certificate']
      end

      private

      def self.jwt_json
        @jwt_json ||= JSON.parse read_jwt_file
      end

      def self.read_jwt_file
        File.read('spec/fixtures/files/jwt.json')
      end
    end
  end
end
