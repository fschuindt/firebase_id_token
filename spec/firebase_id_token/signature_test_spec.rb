require 'spec_helper'

module FirebaseIdToken
  describe Signature do
    let(:jwt) { JSON.parse File.read('spec/fixtures/files/jwt.json') }
    let(:payload) { JSON.parse File.read('spec/fixtures/files/payload.json') }
    let(:rsa_private) { OpenSSL::PKey::RSA.new(FirebaseIdToken::Testing::Certificates.private_key) }

    before :each do
      FirebaseIdToken.configure do |config|
        config.project_ids = ['firebase-id-token']
      end
      FirebaseIdToken.test!
    end

    describe '#verify' do

      it 'test mode is valid' do
        expect(described_class.verify(jwt['jwt_token'])).to be_a(Hash)
      end

      it 'test mode encode is valid' do
        JWT.encode payload, rsa_private, 'RS256'
        expect(described_class.verify(jwt['jwt_token'])).to be_a(Hash)
      end
    end
  end
end
