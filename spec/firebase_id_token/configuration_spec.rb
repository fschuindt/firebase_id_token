require 'spec_helper'

module FirebaseIdToken
  describe Configuration do
    describe '#project_ids' do
      it 'default value is []' do
        Configuration.new.project_ids = []
      end
    end

    describe '#project_ids=' do
      it 'can set value' do
        config = Configuration.new
        config.project_ids = 1
        expect(config.project_ids).to eq(1)
      end
    end
  end
end
