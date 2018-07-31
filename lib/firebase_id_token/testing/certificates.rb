module FirebaseIdToken
  module Testing
    # When executing the test, manage secret key and certificate with Fixture.
    # Valid for Ruby applications using minitest
    # ## Access Certificates.
    # `FirebaseIdToken.test!` is required to start using this class. <br />
    # When implementing minitest, always return the same certificate.
    # Provide secret key for encoding JWT.
    #
    # ## List of available methods
    # + {Certificates.find}
    # + {Certificates.private_key}
    # + {Certificates.certificate}
    class Certificates
      # `.find` is stabbed to always return the same certificate.
      # @param [String] kid Key ID
      # @return [nil, OpenSSL::X509::Certificate]
      def self.find(kid)
        cert = certificate
        OpenSSL::X509::Certificate.new cert
      end

      # Return the secret key defined by Fixture.
      # @return [string]
      # @example `.private_kay`
      #   "-----BEGIN RSA PRIVATE KEY-----
      #   MIICXAIBAAKBgQCrvJRW05yKQxx3+PdiysRKR/N+VqYv9+b/76C3zC/vk9ACkWTN
      #   /dcPMzIXVIdDMU+r1o8HF3mOXNhCFWGSfZ7r1dMe961BQtxu1DagC7Ff+XZZL0Mu
      #   0W0Y/GmP7yTrsie7wCq4QiHj2HBtUtze/uC6DT8Qcthg46LUJBqeh9FiIwIDAQAB
      #   AoGAEGK80I/+Np7yn2vMxstL8T5uOBayYo9HphHKBt9fj39N8IDI2nKmy1d6Jwm0
      #   oi+ZR28AVI/j1DZ9l8iMd7qup+/D5CdTt89u8fTUlQkCjAQQsRBneq5MJRKI+5eA
      #   JDJmx7p7CUUqjnIcFfbBz0NLTDZso11Vp+BDfbDpKv37nskCQQDZimWuxa7rK6UZ
      #   XGDl8LxEiM27US67kDu8iS3VdQWEKIhhQoea/zNKPMkQsc2+CPggQTcG/2WuPEYJ
      #   O1bPz7HPAkEAyhknhziWREEBQRLp4qsakozMIn4iuuaC00zpLwcnyOqFPaHS5CTL
      #   I7GxpwN6Ld1N/nqvYGyk/dRb5Ul7v27DbQJAUMsJwMNCl6z6AFVC16N1CK8WWX9p
      #   L9f9l6QLFcAEcHTtUdH3syUc03GH619d3jpOjQwrd7na9b8E8+DJ+RxWGQJAI8cE
      #   OmoIIBkp8a05fokv8RW/5bNSzqeULXgGJ+8qWeU6pUiKnxzsYWtJuflhndD5x71M
      #   YtOY+d6oThUONTuUmQJBAMGl/eaFU0AfA+xS/3Kt5JFKBbBVAByhL+Hd/27/rYZ5
      #   8YXDUQAgcykCS21JMrn41p4gwJnpG35PoV8qBIW9a94=
      #   -----END RSA PRIVATE KEY-----"

      def self.private_key
        @rsa_private ||= jwt_json['private_key']
      end

      # Return the certificate defined by Fixture.
      # @return [string]
      # @example `.certificate`
      #   -----BEGIN CERTIFICATE-----
      #   MIIChDCCAe2gAwIBAgIBADANBgkqhkiG9w0BAQUFADA6MQswCQYDVQQGEwJCRTEN
      #   MAsGA1UECgwEVGVzdDENMAsGA1UECwwEVGVzdDENMAsGA1UEAwwEVGVzdDAgFw0x
      #   NzA0MjQwMjE5MzRaGA8zMDE2MDgyNTAyMTkzNFowOjELMAkGA1UEBhMCQkUxDTAL
      #   BgNVBAoMBFRlc3QxDTALBgNVBAsMBFRlc3QxDTALBgNVBAMMBFRlc3QwgZ8wDQYJ
      #   KoZIhvcNAQEBBQADgY0AMIGJAoGBAKu8lFbTnIpDHHf492LKxEpH835Wpi/35v/v
      #   oLfML++T0AKRZM391w8zMhdUh0MxT6vWjwcXeY5c2EIVYZJ9nuvV0x73rUFC3G7U
      #   NqALsV/5dlkvQy7RbRj8aY/vJOuyJ7vAKrhCIePYcG1S3N7+4LoNPxBy2GDjotQk
      #   Gp6H0WIjAgMBAAGjgZcwgZQwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUFKl2
      #   nZaaeNZM/7dno9IbaEIvaXQwYgYDVR0jBFswWYAUFKl2nZaaeNZM/7dno9IbaEIv
      #   aXShPqQ8MDoxCzAJBgNVBAYTAkJFMQ0wCwYDVQQKDARUZXN0MQ0wCwYDVQQLDARU
      #   ZXN0MQ0wCwYDVQQDDARUZXN0ggEAMA0GCSqGSIb3DQEBBQUAA4GBAKkBvhUIRENB
      #   ap0r9F7sKkRr8tJCCjBPIA+8e8XIKS3A3w6EI5ErRpv795rO80TBR4WZR9GhH8M1
      #   PXJ7FuaayCcPAl0febjl4z6ZciCSDpBdhbMpmq1d/kYU1H1qUokE2BxhNdcs/Q4w
      #   +5NnFGSkYm09tPzLWFPLoES9ynBF0N7l
      #   -----END CERTIFICATE-----
      #
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
