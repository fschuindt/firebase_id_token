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
        config.project_ids = String.new
        expect(config.project_ids).to be_a(String)
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
