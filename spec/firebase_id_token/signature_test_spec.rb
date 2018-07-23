require 'spec_helper'

module FirebaseIdToken
  describe Signature do
    let(:jwt) { JSON.parse File.read('spec/fixtures/files/jwt.json') }

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
    end
  end
end
