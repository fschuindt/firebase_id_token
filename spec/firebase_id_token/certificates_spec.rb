require 'spec_helper'

module FirebaseIdToken
  describe Certificates do
    let (:redis) { Redis::Namespace.new 'firebase_id_token', redis: Redis.new }
    let (:certs) { File.read('spec/fixtures/files/certificates.json') }
    let (:expires_in) { (DateTime.now + (5/24r)).to_s }
    let (:response) { double }

    let (:mock_response) {
      allow(response).to receive(:code) { 200 }
      allow(response).to receive(:headers) { { 'expires' => expires_in } }
      allow(response).to receive(:body) { certs }
    }

    let(:mock_request) {
      mock_response
      allow(HTTParty).to receive(:get).
        with(an_instance_of(String)) { response }
    }

    before :each do
      redis.del 'certificates'
      mock_request
    end

    describe '#request' do
      it 'requests certificates when Redis database is empty' do
        expect(HTTParty).to receive(:get).
          with(FirebaseIdToken::Certificates::URL)
        described_class.request
      end

      it 'does not requests certificates when Redis database is written' do
        expect(HTTParty).to receive(:get).
          with(FirebaseIdToken::Certificates::URL).once
        2.times { described_class.request }
      end
    end

    describe '#request_anyway' do
      it 'always requests certificates' do
        expect(HTTParty).to receive(:get).
          with(FirebaseIdToken::Certificates::URL).twice
        2.times { described_class.request_anyway }
      end

      it 'sets the certificate expiration time as Redis TTL' do
        described_class.request_anyway
        expect(redis.ttl('certificates')).to be > 3600
      end

      it 'raises a error when certificates expires in less than 1 hour' do
        ttl_30min = (DateTime.now + (1/24r)/2).to_s
        allow(response).to receive(:headers) { { 'expires' => ttl_30min } }
        expect{ described_class.request_anyway }.
          to raise_error(Exceptions::Certificates::TimeToLiveError)
      end
    end

    describe '#present?' do
      it 'returns false when Redis database is empty' do
        expect(described_class.present?).to be(false)
      end

      it 'returns true when Redis database is written' do
        described_class.request
        expect(described_class.present?).to be(true)
      end
    end

    describe '#x509' do
      context 'before requesting certificates' do
        it 'raises a error' do
          expect{ described_class.x509 }.
            to raise_error(Exceptions::Certificates::NoEntityError)
        end
      end

      context 'after requesting certificates' do
        it 'returns a array of hashes: String keys' do
          described_class.request
          expect(described_class.x509.first.keys[0]).to be_a(String)
        end

        it 'returns a array of hashes: OpenSSL::X509::Certificate values' do
          described_class.request
          expect(described_class.x509.first.values[0]).
            to be_a(OpenSSL::X509::Certificate)
        end
      end
    end
  end
end
