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
      generator = instance_double(Snowflake::GeneratorService, next_id: 62)
      allow(Snowflake::GeneratorService).to receive(:new).and_return(generator)

      mapping = create(:link_mapping, redirect_link: 'https://example.com')

      expect(mapping.link_code).to eq(Utils::Base62Service.encode(62))
    end

    it 'generates unique link_codes for each record' do
      mappings = create_list(:link_mapping, 2, redirect_link: 'https://example.com')

      expect(mappings.map(&:link_code).uniq.size).to eq(2)
    end
  end
end
