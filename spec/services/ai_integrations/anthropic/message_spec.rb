require 'rails_helper'

RSpec.describe AiIntegrations::Anthropic::Message do
  let(:api_key) { 'test-api-key' }
  let(:messages_api) { instance_double(Anthropic::Resources::Messages) }
  let(:client) { instance_double(Anthropic::Client, messages: messages_api) }

  before do
    allow(Anthropic::Client).to receive(:new).with(api_key: api_key).and_return(client)
  end

  describe '#initialize' do
    it 'uses the default model when none is given' do
      service = described_class.new(api_key: api_key)

      expect(service.model).to eq(Anthropic::Model::CLAUDE_SONNET_5)
      expect(service.messages).to eq([])
      expect(service.token_count).to eq(0)
    end

    it 'uses a custom model when provided' do
      custom_model = :'claude-haiku-4-5'

      service = described_class.new(api_key: api_key, model: custom_model)

      expect(service.model).to eq(custom_model)
    end

    context 'when no API key is configured' do
      around do |example|
        original = ENV.fetch('ANTHROPIC_API_KEY', nil)
        ENV.delete('ANTHROPIC_API_KEY')
        example.run
      ensure
        if original.nil?
          ENV.delete('ANTHROPIC_API_KEY')
        else
          ENV['ANTHROPIC_API_KEY'] = original
        end
      end

      it 'raises MissingApiKeyError' do
        expect do
          described_class.new
        end.to raise_error(
          described_class::MissingApiKeyError,
          'No Anthropic API key is configured.',
        )
      end
    end

    context 'when the API key comes from the environment' do
      around do |example|
        original = ENV.fetch('ANTHROPIC_API_KEY', nil)
        ENV['ANTHROPIC_API_KEY'] = 'env-api-key'
        example.run
      ensure
        if original.nil?
          ENV.delete('ANTHROPIC_API_KEY')
        else
          ENV['ANTHROPIC_API_KEY'] = original
        end
      end

      before do
        allow(Anthropic::Client).to receive(:new).with(api_key: 'env-api-key').and_return(client)
      end

      it 'warns that the default key is in use' do
        allow(Rails.logger).to receive(:warn)

        described_class.new

        expect(Rails.logger).to have_received(:warn).with(
          '[Anthropic][Messages] Using the default Anthropic API key.',
        )
      end
    end
  end

  describe '#chat' do
    subject(:service) { described_class.new(api_key: api_key) }

    it 'returns an empty array when content is blank' do
      expect(messages_api).not_to receive(:create)

      expect(service.chat(content: nil)).to eq([])
      expect(service.chat(content: '')).to eq([])
      expect(service.chat(content: '   ')).to eq([])
    end

    it 'calls the API, updates conversation state, and returns assistant messages' do
      text_block = instance_double('TextBlock', type: :text, text: 'Hi there')
      usage = instance_double('Usage', input_tokens: 12, output_tokens: 8)
      response = instance_double(
        'AnthropicResponse',
        role: 'assistant',
        content: [ text_block ],
        usage: usage,
      )

      allow(messages_api).to receive(:count_tokens).and_return(
        instance_double('TokenCount', input_tokens: 5),
      )
      allow(messages_api).to receive(:create).and_return(response)

      result = service.chat(content: 'Hello')

      expect(messages_api).to have_received(:count_tokens).with(
        model: Anthropic::Model::CLAUDE_SONNET_5,
        messages: [ { role: :user, content: 'Hello' } ],
      )
      expect(messages_api).to have_received(:create).with(
        max_tokens: described_class::MAX_ANTHROPIC_OUTPUT_TOKENS,
        model: Anthropic::Model::CLAUDE_SONNET_5,
        messages: [ { role: :user, content: 'Hello' } ],
      )
      expect(result).to eq([ { role: :assistant, content: 'Hi there' } ])
      expect(service.messages).to eq(
        [
          { role: :user, content: 'Hello' },
          { role: :assistant, content: 'Hi there' }
        ],
      )
      expect(service.token_count).to eq(20)
    end

    it 'skips non-text content blocks in the API response' do
      text_block = instance_double('TextBlock', type: :text, text: 'Visible')
      image_block = instance_double('ImageBlock', type: :image)
      usage = instance_double('Usage', input_tokens: 1, output_tokens: 1)
      response = instance_double(
        'AnthropicResponse',
        role: 'assistant',
        content: [ image_block, text_block ],
        usage: usage,
      )

      allow(Rails.logger).to receive(:warn)
      allow(messages_api).to receive(:count_tokens).and_return(
        instance_double('TokenCount', input_tokens: 1),
      )
      allow(messages_api).to receive(:create).and_return(response)

      result = service.chat(content: 'Show me something')

      expect(Rails.logger).to have_received(:warn).with(
        '[Anthropic][Messages] Skipping non-text content block (image) in the Anthropic response.',
      )
      expect(result).to eq([ { role: :assistant, content: 'Visible' } ])
    end

    it 'raises TooManyTokensError when input tokens exceed the limit' do
      allow(messages_api).to receive(:count_tokens).and_return(
        instance_double('TokenCount', input_tokens: described_class::MAX_USER_INPUT_TOKENS + 1),
      )
      expect(messages_api).not_to receive(:create)

      expect do
        service.chat(content: 'Too long')
      end.to raise_error(
        described_class::TooManyTokensError,
        /Input token count \(\d+\) exceeds the maximum allowed \(#{described_class::MAX_USER_INPUT_TOKENS}\)/,
      )
    end
  end
end
