require 'spec_helper'

# The ActiveSupport store lazily downloads certificates whenever it is
# instantiated over an empty cache, while the legacy Redis store only
# downloads them upon an explicit request. Examples whose outcome depends on
# the empty-cache behavior branch on the `lazy` option.
shared_examples_for 'a certificate store' do |opts = {}|
  lazy = opts.fetch(:lazy, false)

  before :each do
    mock_request
  end

  describe '#request' do
    it 'requests certificates when the cache is empty' do
      expect(HTTParty).to receive(:get).
        with(FirebaseIdToken::Certificates::URL)
      described_class.request
    end

    it 'does not requests certificates when the cache is written' do
      expect(HTTParty).to receive(:get).
        with(FirebaseIdToken::Certificates::URL).once
      2.times { described_class.request }
    end
  end

  describe '#request!' do
    if lazy
      it 'always requests certificates' do
        # The store lazily loads the empty cache once before the first
        # explicit request, hence the extra call.
        expect(HTTParty).to receive(:get).
          with(FirebaseIdToken::Certificates::URL).exactly(3).times
        2.times { described_class.request! }
      end
    else
      it 'always requests certificates' do
        expect(HTTParty).to receive(:get).
          with(FirebaseIdToken::Certificates::URL).twice
        2.times { described_class.request! }
      end
    end

    it 'sets the certificate expiration time as the cache TTL' do
      described_class.request!
      expect(described_class.ttl).to be > 3600
    end

    it 'raises a error when certificates expires in less than 1 hour' do
      allow(response).to receive(:headers) {{'cache-control' => low_cache}}
        expect{ described_class.request! }.
          to raise_error(FirebaseIdToken::Exceptions::CertificatesTtlError)
    end

    it 'raises a error when HTTP response code is other than 200' do
      allow(response).to receive(:code) { 401 }
      expect{ described_class.request! }.
        to raise_error(FirebaseIdToken::Exceptions::CertificatesRequestError)
    end
  end

  describe '#request_anyway' do
    if lazy
      it 'also requests certificates' do
        expect(HTTParty).to receive(:get).
          with(FirebaseIdToken::Certificates::URL).twice
        described_class.request_anyway
      end
    else
      it 'also requests certificates' do
        expect(HTTParty).to receive(:get).
          with(FirebaseIdToken::Certificates::URL)
        described_class.request_anyway
      end
    end
  end

  describe '.present?' do
    if lazy
      it 'returns true when the cache is empty, lazily fetching' do
        expect(described_class.present?).to be(true)
      end
    else
      it 'returns false when the cache is empty' do
        expect(described_class.present?).to be(false)
      end
    end

    it 'returns true when the cache is written' do
      described_class.request
      expect(described_class.present?).to be(true)
    end
  end

  describe '.all' do
    context 'before requesting certificates' do
      if lazy
        it 'lazily fetches and returns the certificates' do
          expect(described_class.all.first.values[0]).
            to be_a(OpenSSL::X509::Certificate)
        end
      else
        it 'returns a empty Array' do
          expect(described_class.all).to eq([])
        end
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
    context 'without certificates in the cache' do
      if lazy
        it 'lazily fetches certificates and finds the kid' do
          expect(described_class.find(kid)).to be_a(OpenSSL::X509::Certificate)
        end
      else
        it 'raises a exception' do
          expect{ described_class.find(kid)}.
            to raise_error(FirebaseIdToken::Exceptions::NoCertificatesError)
        end
      end
    end

    context 'with certificates in the cache' do
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

  describe '.find!' do
    context 'without certificates in the cache' do
      if lazy
        it 'lazily fetches certificates and finds the kid' do
          expect(described_class.find!(kid)).to be_a(OpenSSL::X509::Certificate)
        end
      else
        it 'raises a exception' do
          expect{ described_class.find!(kid)}.
            to raise_error(FirebaseIdToken::Exceptions::NoCertificatesError)
        end
      end
    end

    context 'with certificates in the cache' do
      it 'returns a OpenSSL::X509::Certificate when it finds the kid' do
        described_class.request
        expect(described_class.find!(kid)).to be_a(OpenSSL::X509::Certificate)
      end

      it 'raises a CertificateNotFound error when it can not find the kid' do
        described_class.request
        expect { described_class.find!('') }
          .to raise_error(FirebaseIdToken::Exceptions::CertificateNotFound, /Unable to find/)
      end
    end

  end

  describe '.ttl' do
    it 'returns a positive number when has certificates in the cache' do
      described_class.request
      expect(described_class.ttl).to be > 0
    end

    if lazy
      it 'returns a positive number when the cache is empty, lazily fetching' do
        expect(described_class.ttl).to be > 0
      end
    else
      it 'returns zero when has no certificates in the cache' do
        expect(described_class.ttl).to eq(0)
      end
    end
  end
end
