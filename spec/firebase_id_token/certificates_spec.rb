require 'spec_helper'

module FirebaseIdToken
  describe Certificates do
    describe '#download' do
      it 'downloads public keys when it have not yet' do
      end

      it 'does not downloads public keys when it have already downloaded' do
      end
    end

    describe '#download!' do
      it 'always downloads public keys' do
      end
    end

    describe '#x509' do
      it 'returns a Array with the downloaded keys as x508 certificates' do
      end

      it 'raises a error when there is no downloaded keys' do
      end
    end
  end
end
