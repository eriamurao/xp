class LinkMapping < ApplicationRecord
  # Base62 snowflake ids are 4-11 chars (4 after the first ms past epoch; 11 max for 63-bit ids).
  LINK_CODE_FORMAT = /\A[0-9a-zA-Z]{4,11}\z/

  validates :link_code, presence: true, uniqueness: true, format: { with: LINK_CODE_FORMAT }
  validates :redirect_link, presence: true

  validate :long_url_must_be_valid

  before_validation :generate_link_code, on: :create

  after_update :remove_cached_code, if: -> { saved_change_to_redirect_link? || saved_change_to_link_code? }
  after_destroy :remove_cached_code

  def self.generate_mock_data(count: 100)
    count.times do |i|
      Rails.logger.info("Generating mock data #{i + 1} of #{count}")
      LinkMapping.create(redirect_link: Faker::Internet.url)
    end
  end

  def self.cache_key(code)
    "link_mapping:#{code}"
  end

  def safe_redirect_link
    return nil if redirect_link.blank?

    uri = URI.parse(redirect_link)
    uri.is_a?(URI::HTTP) && uri.host.present? ? uri.to_s : nil
  rescue URI::InvalidURIError
    nil
  end

  private

  def long_url_must_be_valid
    return if redirect_link.blank?

    if safe_redirect_link.blank?
      errors.add(:redirect_link, 'must be a valid http or https URL')
    end
  end

  def generate_link_code
    return if link_code.present?

    next_id = Snowflake::GeneratorService.new.next_id
    self.link_code = Utils::Base62Service.encode(next_id)
  end

  def remove_cached_code
    [ link_code, link_code_before_last_save ].compact.uniq.each do |code|
      Rails.cache.delete(self.class.cache_key(code))
    end
  end
end
