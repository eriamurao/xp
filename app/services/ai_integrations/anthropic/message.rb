require 'anthropic'

module AiIntegrations
  module Anthropic
    class Message
      MAX_USER_INPUT_TOKENS = 8192
      MAX_ANTHROPIC_OUTPUT_TOKENS = 1024

      class MissingApiKeyError < StandardError; end
      class TooManyTokensError < StandardError; end

      attr_reader :messages, :model, :token_count

      def initialize(api_key: nil, model: nil)
        @api_key = api_key
        @model = model.presence || default_model
        @token_count = 0
        @messages = []

        validate_api_key!
      end

      def chat(content: nil)
        return [] if content.blank?

        new_message = { role: :user, content: content }
        pending_messages = @messages + [ new_message ]

        validate_token_limit!(pending_messages)

        response = client.messages.create(
          max_tokens: MAX_ANTHROPIC_OUTPUT_TOKENS,
          model: @model,
          messages: pending_messages,
        )

        @messages << new_message

        response_messages = extract_messages(response)
        @messages.concat(response_messages)

        @token_count = response.usage.input_tokens + response.usage.output_tokens

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
        if configured_api_key.blank?
          error_message = 'No Anthropic API key is configured.'

          logger.error(error_message)
          raise MissingApiKeyError, error_message
        end

        logger.warn('Using the default Anthropic API key.') if @api_key.blank?
      end

      def count_tokens_for(messages)
        return 0 if messages.blank?

        response = client.messages.count_tokens(
          model: @model,
          messages: messages,
        )
        response.input_tokens
      end

      def validate_token_limit!(messages)
        input_tokens = count_tokens_for(messages)

        return if input_tokens <= MAX_USER_INPUT_TOKENS

        error_message = "Input token count (#{input_tokens}) exceeds the maximum allowed (#{MAX_USER_INPUT_TOKENS})."
        logger.error(error_message)
        raise TooManyTokensError, error_message
      end

      def extract_messages(response)
        response.content.filter_map do |block|
          unless block.type == :text
            logger.warn("Skipping non-text content block (#{block.type}) in the Anthropic response.")
            next
          end

          { role: response.role&.to_sym || :assistant, content: block.text }
        end
      end
    end
  end
end
