require 'spec_helper'
require 'redis'
require 'redis-namespace'
require 'firebase_id_token/certificates/redis'

module FirebaseIdToken
  describe Certificates::Redis do
    let (:redis) { Redis::Namespace.new 'firebase_id_token', redis: Redis.new }
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

    before :each do
      redis.del 'certificates'
    end

    it_behaves_like 'a certificate store'
  end
end
