require 'spec_helper'

module FirebaseIdToken
  describe Signature do
    let(:jwt) { JSON.parse File.read('spec/fixtures/files/jwt.json') }
    let(:raise_certificates_error) { false }

    let(:mock_certificates) do
      allow(Certificates)
        .to(receive(:find))
        .with(an_instance_of(String), raise_error: raise_certificates_error,
          source: :id_token)
        .and_return(OpenSSL::X509::Certificate.new(jwt['certificate']))
    end

    before :each do
      mock_certificates
      FirebaseIdToken.configure do |config|
        config.project_ids = ['firebase-id-token']
      end
    end

    describe '#verify' do
      it 'returns a Hash when the signature is valid' do
        expect(described_class.verify(jwt['jwt_token'])).to be_a(Hash)
      end

      it 'returns nil when the signature is invalid' do
        expect(described_class.verify(jwt['bad_jwt_token'])).to be(nil)
      end

      it 'returns nil with a invalid key format' do
        expect(described_class.verify('aaa')).to be(nil)
      end

      it 'returns nil when the token has no sub claim' do
        payload = {
          'iss' => 'https://securetoken.google.com/firebase-id-token',
          'aud' => 'firebase-id-token',
          'exp' => Time.now.to_i + 3600,
          'iat' => Time.now.to_i - 60
        }
        token = JWT.encode(payload,
          OpenSSL::PKey::RSA.new(jwt['private_key']), 'RS256', kid: 'test')

        expect(described_class.verify(token)).to be(nil)
      end
    end

    describe '#verify!' do
      let(:raise_certificates_error) { true }
      it 'returns a Hash when the signature is valid' do
        expect(described_class.verify!(jwt['jwt_token'])).to be_a(Hash)
      end

      it 'raises an error when the signature is invalid' do
        expect { described_class.verify!(jwt['bad_jwt_token']) }
          .to raise_error(JWT::VerificationError)
      end

      it 'raises an error with a invalid key format' do
        expect { described_class.verify!('aaa') }
          .to raise_error(JWT::DecodeError, /too many/)
      end
    end
  end
end
