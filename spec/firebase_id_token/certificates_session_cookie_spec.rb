require 'spec_helper'

module FirebaseIdToken
  describe 'Certificates with the session cookie source' do
    let (:certs) { File.read('spec/fixtures/files/certificates.json') }
    let (:cache) { 'public, max-age=19302, must-revalidate, no-transform' }
    let (:kid) { JSON.parse(certs).first[0] }
    let (:response) { double }

    before :each do
      allow(response).to receive(:code) { 200 }
      allow(response).to receive(:headers) { { 'cache-control' => cache } }
      allow(response).to receive(:body) { certs }
      allow(HTTParty).to receive(:get).with(an_instance_of(String)) { response }
      allow(FirebaseIdToken.configuration).to receive(:cache_store).and_return(
        ActiveSupport::Cache::MemoryStore.new(namespace: 'firebase_auth'))
    end

    after :each do
      FirebaseIdToken.reset
    end

    it 'requests the session cookie certificates URL' do
      expect(HTTParty).to receive(:get).
        with(Certificates::SESSION_COOKIE_URL).at_least(:once) { response }

      Certificates.request!(source: :session_cookie)
    end

    it 'stores session cookie certificates apart from ID Token ones' do
      Certificates.request!(source: :session_cookie)
      cache_store = FirebaseIdToken.configuration.cache_store

      expect(cache_store.read('session_cookie_certificates')).not_to be_nil
      expect(cache_store.read('certificates')).to be_nil
    end

    it 'finds a certificate by kid on the session cookie source' do
      expect(Certificates.find(kid, source: :session_cookie)).
        to be_a(OpenSSL::X509::Certificate)
    end

    it 'reports the TTL of the session cookie source' do
      Certificates.request!(source: :session_cookie)

      expect(Certificates.ttl(source: :session_cookie)).to be > 3600
    end
  end
end
