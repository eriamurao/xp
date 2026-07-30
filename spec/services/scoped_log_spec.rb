require 'rails_helper'

RSpec.describe ScopedLog::Logger do
  subject(:logger) { described_class.new }

  describe '#scope' do
    it 'returns a new logger with additional scope segments' do
      scoped = logger.scope('Anthropic').scope('Messages')

      expect(scoped).to be_a(described_class)
      expect(scoped).not_to equal(logger)
    end
  end

  %i[info warn error debug].each do |level|
    describe "##{level}" do
      it 'writes a prefixed message to Rails.logger' do
        allow(Rails.logger).to receive(level)
        scoped = logger.scope('Anthropic').scope('Messages')

        scoped.public_send(level, 'request started')

        expect(Rails.logger).to have_received(level).with('[Anthropic][Messages] request started')
      end

      it 'returns nil and does not log when the message is nil' do
        allow(Rails.logger).to receive(level)

        expect(logger.public_send(level, nil)).to be_nil
        expect(Rails.logger).not_to have_received(level)
      end

      it 'returns nil and does not log when the message is not a String' do
        allow(Rails.logger).to receive(level)

        expect(logger.public_send(level, 123)).to be_nil
        expect(Rails.logger).not_to have_received(level)
      end
    end
  end

  describe 'with no scopes' do
    it 'prefixes the message with a trailing space only' do
      allow(Rails.logger).to receive(:info)

      logger.info('plain')

      expect(Rails.logger).to have_received(:info).with(' plain')
    end
  end
end
