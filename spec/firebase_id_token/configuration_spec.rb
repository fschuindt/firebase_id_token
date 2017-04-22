require 'spec_helper'

module FirebaseIdToken
  describe Configuration do
    describe '.project_ids' do
      it 'sets [] as default' do
        expect(Configuration.new.project_ids).to eq([])
      end
    end

    describe '.project_ids=' do
      it 'changes default values' do
        config = Configuration.new
        config.project_ids = 1
        expect(config.project_ids).to eq(1)
      end
    end

    describe '.redis' do
      it 'sets a Redis instance as default' do
        expect(Configuration.new.redis).to be_a(Redis)
      end
    end

    describe '.redis=' do
      it 'changes default values' do
        config = Configuration.new
        config.redis = String.new
        expect(config.redis).to be_a(String)
      end
    end
  end
end
