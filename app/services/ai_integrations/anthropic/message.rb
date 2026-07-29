require 'anthropic'

module AiIntegrations
  module Anthropic
    class Message
      class MissingApiKeyError < StandardError; end

      attr_reader :messages

      def initialize(api_key: nil)
        @api_key = api_key
        @messages = []

        validate_api_key!
      end

      def chat(model: nil, content: nil)
        return nil if content.blank?

        @messages << { role: :user, content: content }

        response = client.messages.create(
          max_tokens: 1024,
          model: model.presence || default_model,
          messages: messages,
        )

        response_messages = extract_messages(response)
        @messages.concat(response_messages)

        response_messages
      end

      private

      def logger
        @logger ||= ::ScopedLog::Logger.new([ 'Anthropic', 'Messages' ])
      end

      def default_api_key
        ENV.fetch('ANTHROPIC_API_KEY', nil)
      end

      def default_model
        ::Anthropic::Model::CLAUDE_SONNET_5
      end

      def client
        @client ||= ::Anthropic::Client.new(api_key: configured_api_key)
      end

      def configured_api_key
        @api_key.presence || default_api_key
      end

      def validate_api_key!
        raise MissingApiKeyError, 'No Anthropic API key is configured.' if configured_api_key.blank?

        logger.warn('Using the default Anthropic API key.') if @api_key.blank?
      end

      def extract_messages(response)
        response.content.filter_map do |c|
          next unless c.type == :text

          { role: response.role&.to_sym || :assistant, content: c.text }
        end
      end
    end
  end
end
