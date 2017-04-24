require 'spec_helper'

module FirebaseIdToken
  describe Signature do
    let(:jwt) { JSON.parse File.read('spec/fixtures/files/jwt.json') }

    let (:mock_certificates) {
      allow(Certificates).to receive(:find).with(an_instance_of(String)) {
        OpenSSL::X509::Certificate.new(jwt['certificate']) }
    }

    before :each do
      mock_certificates
      FirebaseIdToken.configure do |config|
        config.project_ids = ['firebase-id-token']
      end
    end

    describe '#verify' do
      it 'returns the JWT payload when the signature is valid' do
        expect(described_class.verify(jwt['jwt_token'])).to be_a(Hash)
      end

      it 'raises a exception when the signature is invalid' do
        expect{ described_class.verify(jwt['bad_jwt_token']) }.
          to raise_error(JWT::VerificationError)
      end
    end
  end
end
