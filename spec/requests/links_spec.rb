require 'rails_helper'

RSpec.describe 'Links', type: :request do
  describe 'POST /links/generate_short_url' do
    let(:long_url) { 'https://example.com/some/path' }

    it 'creates a mapping and returns the short URL' do
      expect do
        post generate_short_url_links_path, params: { long_url: long_url }
      end.to change(LinkMapping, :count).by(1)

      expect(response).to have_http_status(:created)

      mapping = LinkMapping.last
      body = response.parsed_body

      expect(body['short_url']).to include("/links/#{mapping.link_code}")
      expect(mapping.redirect_link).to eq(long_url)
    end

    it 'returns validation errors for an invalid long URL' do
      expect do
        post generate_short_url_links_path, params: { long_url: 'not a url' }
      end.not_to change(LinkMapping, :count)

      expect(response).to have_http_status(:unprocessable_entity)

      body = response.parsed_body
      expect(body['error']).to be_an(Array)
      expect(body['error']).not_to be_empty
    end

    it 'returns validation errors when long_url is missing' do
      post generate_short_url_links_path, params: {}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['error']).to be_present
    end
  end

  describe 'GET /links/:id' do
    it 'redirects to the stored URL with a temporary redirect' do
      mapping = create(:link_mapping, redirect_link: 'https://destination.example/target')

      get link_path(mapping.link_code)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to('https://destination.example/target')
    end

    it 'returns not found when the link code does not exist' do
      get link_path('missing-code')

      expect(response).to have_http_status(:not_found)
      expect(response.body).to be_blank
    end
  end
end
