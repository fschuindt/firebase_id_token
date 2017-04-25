require 'spec_helper'

RSpec.describe FirebaseIdToken do
  let(:jwt) { JSON.parse File.read('spec/fixtures/files/jwt.json') }

  let (:mock_certificates) {
    allow(FirebaseIdToken::Certificates).to receive(:find).
      with(an_instance_of(String)) {
        OpenSSL::X509::Certificate.new(jwt['certificate']) }
  }

  it 'has a version number' do
    expect(FirebaseIdToken::VERSION).not_to be nil
  end

  describe '#configure' do
    before :each do
      mock_certificates
      FirebaseIdToken.configure do |config|
        config.project_ids = ['firebase-id-token']
      end
    end

    it 'sets global project_ids' do
      expect(FirebaseIdToken::Signature.verify(jwt['jwt_token'])).to be_a(Hash)
    end

    after :each do
      FirebaseIdToken.reset
    end
  end

  describe '#reset' do
    before :each do
      FirebaseIdToken.configure do |config|
        config.project_ids = 1
      end
    end

    it 'resets the configuration' do
      FirebaseIdToken.reset
      config = FirebaseIdToken.configuration
      expect(config.project_ids).to eq([])
    end
  end
end
