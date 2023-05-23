require 'spec_helper'
require 'firebase_id_token/certificates/active_support'

module FirebaseIdToken
  describe Certificates::ActiveSupport do
    let (:certs) { File.read('spec/fixtures/files/certificates.json') }
    let (:cache) { 'public, max-age=19302, must-revalidate, no-transform' }
    let (:low_cache) { 'public, max-age=2160, must-revalidate, no-transform' }
    let (:kid) { JSON.parse(certs).first[0] }
    let (:expires_in) { (DateTime.now + (5/24r)).to_s }
    let (:response) { double }

    let (:mock_response) {
      allow(response).to receive(:code) { 200 }
      allow(response).to receive(:headers) { { 'cache-control' => cache } }
      allow(response).to receive(:body) { certs }
    }

    let(:mock_request) {
      mock_response
      allow(HTTParty).to receive(:get).
        with(an_instance_of(String)) { response }
    }

    context 'RedisCacheStore' do
      before :each do
        allow(FirebaseIdToken.configuration).to receive(:cache_store).and_return(
          ActiveSupport::Cache::RedisCacheStore.new)
        FirebaseIdToken.configuration.cache_store.delete 'certificates'
      end
      it_behaves_like 'a certificate store'
    end

    context 'MemoryStore' do
      before :each do
        allow(FirebaseIdToken.configuration).to receive(:cache_store).and_return(
          ActiveSupport::Cache::MemoryStore.new(namespace: "firebase_auth"))
        FirebaseIdToken.configuration.cache_store.delete 'certificates'
      end
      it_behaves_like 'a certificate store'
    end
  end
end
