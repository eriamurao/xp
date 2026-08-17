require 'rails_helper'

RSpec.describe LinkMapping, type: :model do
  describe 'validations' do
    it 'is valid with required attributes' do
      expect(build(:link_mapping)).to be_valid
    end

    it 'requires redirect_link' do
      mapping = build(:link_mapping, redirect_link: nil)

      expect(mapping).not_to be_valid
      expect(mapping.errors[:redirect_link]).to include("can't be blank")
    end

    it 'requires link_code when not creating' do
      mapping = create(:link_mapping)
      mapping.link_code = nil

      expect(mapping).not_to be_valid
      expect(mapping.errors[:link_code]).to include("can't be blank")
    end

    it 'requires link_code to be unique' do
      first = create(:link_mapping, redirect_link: 'https://example.com/a')
      second = create(:link_mapping, redirect_link: 'https://example.com/b')
      second.link_code = first.link_code

      expect(second).not_to be_valid
      expect(second.errors[:link_code]).to include('has already been taken')
    end

    it 'requires link_code to match the allowed format' do
      mapping = build(:link_mapping, link_code: 'invalid!')

      expect(mapping).not_to be_valid
      expect(mapping.errors[:link_code]).to be_present
    end

    it 'rejects link codes that are too short' do
      mapping = build(:link_mapping, link_code: 'abc')

      expect(mapping).not_to be_valid
      expect(mapping.errors[:link_code]).to be_present
    end

    it 'rejects link codes that are too long' do
      mapping = build(:link_mapping, link_code: 'abcdefghijklmnop')

      expect(mapping).not_to be_valid
      expect(mapping.errors[:link_code]).to be_present
    end

    it 'accepts a valid https URL' do
      mapping = build(:link_mapping, redirect_link: 'https://example.com/path?q=1')

      expect(mapping).to be_valid
    end

    it 'rejects non-http(s) URLs' do
      mapping = build(:link_mapping, redirect_link: 'ftp://example.com/file')

      expect(mapping).not_to be_valid
      expect(mapping.errors[:redirect_link]).to include('must be a valid http or https URL')
    end

    it 'rejects URLs without a host' do
      mapping = build(:link_mapping, redirect_link: 'http://')

      expect(mapping).not_to be_valid
      expect(mapping.errors[:redirect_link]).to include('must be a valid http or https URL')
    end

    it 'rejects malformed URLs' do
      mapping = build(:link_mapping, redirect_link: 'not a url')

      expect(mapping).not_to be_valid
      expect(mapping.errors[:redirect_link]).to include('must be a valid http or https URL')
    end
  end

  describe '#safe_redirect_link' do
    it 'returns the URL for a valid https link' do
      mapping = build(:link_mapping, redirect_link: 'https://example.com/path')

      expect(mapping.safe_redirect_link).to eq('https://example.com/path')
    end

    it 'returns nil for non-http(s) schemes' do
      mapping = build(:link_mapping, redirect_link: 'javascript:alert(1)')

      expect(mapping.safe_redirect_link).to be_nil
    end

    it 'returns nil for malformed URLs' do
      mapping = build(:link_mapping, redirect_link: 'not a url')

      expect(mapping.safe_redirect_link).to be_nil
    end
  end

  describe 'link_code generation' do
    it 'generates link_code from a snowflake id on create' do
      snowflake_id = 4_194_304
      generator = instance_double(Snowflake::GeneratorService, next_id: snowflake_id)
      allow(Snowflake::GeneratorService).to receive(:new).and_return(generator)

      mapping = create(:link_mapping, link_code: nil, redirect_link: 'https://example.com')

      expect(mapping.link_code).to eq(Utils::Base62Service.encode(snowflake_id))
    end

    it 'preserves an existing link_code on create' do
      expect(Snowflake::GeneratorService).not_to receive(:new)

      mapping = create(:link_mapping, link_code: 'customcode1', redirect_link: 'https://example.com')

      expect(mapping.link_code).to eq('customcode1')
    end

    it 'generates link_codes that match LINK_CODE_FORMAT' do
      mapping = create(:link_mapping, link_code: nil, redirect_link: 'https://example.com')

      expect(mapping.link_code).to match(LinkMapping::LINK_CODE_FORMAT)
    end

    it 'generates unique link_codes for each record' do
      mappings = create_list(:link_mapping, 2, link_code: nil, redirect_link: 'https://example.com')

      expect(mappings.map(&:link_code).uniq.size).to eq(2)
    end
  end

  describe 'cache invalidation' do
    around do |example|
      original_cache = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      example.run
    ensure
      Rails.cache = original_cache
    end

    it 'removes the cached redirect on destroy' do
      mapping = create(:link_mapping, redirect_link: 'https://example.com/original')
      cache_key = described_class.cache_key(mapping.link_code)

      Rails.cache.write(cache_key, mapping.safe_redirect_link)
      mapping.destroy!

      expect(Rails.cache.read(cache_key)).to be_nil
    end

    it 'removes the cached redirect when redirect_link is updated' do
      mapping = create(:link_mapping, redirect_link: 'https://example.com/original')
      cache_key = described_class.cache_key(mapping.link_code)

      Rails.cache.write(cache_key, mapping.safe_redirect_link)
      mapping.update!(redirect_link: 'https://example.com/updated')

      expect(Rails.cache.read(cache_key)).to be_nil
    end
  end

  describe '.generate_mock_data' do
    before do
      allow(Rails.logger).to receive(:info)
    end
    it 'creates the requested number of link mappings' do
      expect do
        described_class.generate_mock_data(count: 3)
      end.to change(described_class, :count).by(3)
    end

    it 'generates link codes for each record' do
      described_class.generate_mock_data(count: 2)

      expect(described_class.last(2).map(&:link_code)).to all(be_present)
    end

    it 'logs progress for each record' do
      described_class.generate_mock_data(count: 2)

      expect(Rails.logger).to have_received(:info).with('Generating mock data 1 of 2').ordered
      expect(Rails.logger).to have_received(:info).with('Generating mock data 2 of 2').ordered
    end
  end
end
