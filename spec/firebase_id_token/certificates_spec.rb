require 'spec_helper'

module FirebaseIdToken
  describe Certificates do
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

    describe '#request!' do
      it 'always requests certificates' do
        expect(HTTParty).to receive(:get).
          with(FirebaseIdToken::Certificates::URL).twice
        2.times { described_class.request! }
      end

      it 'sets the certificate expiration time as Redis TTL' do
        described_class.request!
        expect(redis.ttl('certificates')).to be > 3600
      end

      it 'raises a error when certificates expires in less than 1 hour' do
        allow(response).to receive(:headers) {{'cache-control' => low_cache}}
        expect{ described_class.request! }.
          to raise_error(Exceptions::CertificatesTtlError)
      end

      it 'raises a error when HTTP response code is other than 200' do
        allow(response).to receive(:code) { 401 }
        expect{ described_class.request! }.
          to raise_error(Exceptions::CertificatesRequestError)
      end
    end

    describe '#request_anyway' do
      it 'also requests certificates' do
        expect(HTTParty).to receive(:get).
          with(FirebaseIdToken::Certificates::URL)

        described_class.request_anyway
      end
    end

    describe '.present?' do
      it 'returns false when Redis database is empty' do
        expect(described_class.present?).to be(false)
      end

      it 'returns true when Redis database is written' do
        described_class.request
        expect(described_class.present?).to be(true)
      end
    end

    describe '.all' do
      context 'before requesting certificates' do
        it 'returns a empty Array' do
          expect(described_class.all).to eq([])
        end
      end

      context 'after requesting certificates' do
        it 'returns a array of hashes: String keys' do
          described_class.request
          expect(described_class.all.first.keys[0]).to be_a(String)
        end

        it 'returns a array of hashes: OpenSSL::X509::Certificate values' do
          described_class.request
          expect(described_class.all.first.values[0]).
            to be_a(OpenSSL::X509::Certificate)
        end
      end
    end

    describe '.find' do
      context 'without certificates in Redis database' do
        it 'raises a exception' do
          expect{ described_class.find(kid)}.
            to raise_error(Exceptions::NoCertificatesError)
        end
      end

      context 'with certificates in Redis database' do
        it 'returns a OpenSSL::X509::Certificate when it finds the kid' do
          described_class.request
          expect(described_class.find(kid)).to be_a(OpenSSL::X509::Certificate)
        end

        it 'returns nil when it can not find the kid' do
          described_class.request
          expect(described_class.find('')).to be(nil)
        end
      end
    end

    describe '.ttl' do
      it 'returns a positive number when has certificates in Redis' do
        described_class.request
        expect(described_class.ttl).to be > 0
      end

      it 'returns zero when has no certificates in Redis' do
        expect(described_class.ttl).to eq(0)
      end
    end
  end
end
