require 'spec_helper'

module FirebaseIdToken
  describe Signature do
    let(:jwt) { JSON.parse File.read('spec/fixtures/files/jwt.json') }
    let(:raise_certificates_error) { false }

    let(:mock_certificates) do
      allow(Certificates)
        .to(receive(:find))
        .with(an_instance_of(String), raise_error: raise_certificates_error)
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
