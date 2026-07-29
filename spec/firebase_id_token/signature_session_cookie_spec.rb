require 'spec_helper'

module FirebaseIdToken
  describe Signature do
    describe 'verifying a Session Cookie' do
      let(:jwt) { JSON.parse File.read('spec/fixtures/files/jwt.json') }
      let(:rsa_private) { OpenSSL::PKey::RSA.new(jwt['private_key']) }

      let(:session_cookie_payload) do
        {
          'iss' => 'https://session.firebase.google.com/firebase-id-token',
          'aud' => 'firebase-id-token',
          'sub' => 'user-123',
          'iat' => Time.current.to_i - 10,
          'exp' => Time.current.to_i + 3600
        }
      end

      let(:session_cookie) do
        JWT.encode session_cookie_payload, rsa_private, 'RS256', kid: 'test'
      end

      let(:mock_certificates) do
        allow(Certificates)
          .to(receive(:find))
          .with(an_instance_of(String), raise_error: false, source: anything)
          .and_return(OpenSSL::X509::Certificate.new(jwt['certificate']))
      end

      before :each do
        mock_certificates
        FirebaseIdToken.configure do |config|
          config.project_ids = ['firebase-id-token']
        end
      end

      after :each do
        FirebaseIdToken.reset
      end

      it 'returns the payload with type: :session_cookie' do
        expect(described_class.verify(session_cookie, type: :session_cookie)).
          to be_a(Hash)
      end

      it 'looks up certificates on the session cookie source' do
        expect(Certificates).to receive(:find).
          with(an_instance_of(String), raise_error: false,
            source: :session_cookie).
          and_return(OpenSSL::X509::Certificate.new(jwt['certificate']))

        described_class.verify(session_cookie, type: :session_cookie)
      end

      it 'returns nil when verifying a Session Cookie as an ID Token' do
        expect(described_class.verify(session_cookie)).to be(nil)
      end

      it 'returns nil when verifying an ID Token as a Session Cookie' do
        expect(described_class.verify(jwt['jwt_token'], type: :session_cookie)).
          to be(nil)
      end
    end
  end
end
