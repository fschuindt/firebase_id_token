require 'spec_helper'

RSpec.describe FirebaseIdToken do
  it 'has a version number' do
    expect(FirebaseIdToken::VERSION).not_to be nil
  end

  describe '#configure' do
    before :each do
      FirebaseIdToken.configure do |config|
        config.project_ids = ['my-project-id', 'another-project-id']
      end
    end

    it 'sets global project_ids' do
      project_ids = FirebaseIdToken::Signature.new('token').project_ids
      expect(project_ids).to be_a(Array)
      expect(project_ids.size).to eq(2)
    end

    after :each do
      FirebaseIdToken.reset
    end
  end

  describe '#reset' do
    before :each do
      FirebaseIdToken.configure do |config|
        config.project_ids = 1
      end
    end

    it 'resets the configuration' do
      FirebaseIdToken.reset
      config = FirebaseIdToken.configuration
      expect(config.project_ids).to eq([])
    end
  end
end
