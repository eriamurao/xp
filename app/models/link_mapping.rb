class LinkMapping < ApplicationRecord
  validates :link_code, presence: true, uniqueness: true
  validates :redirect_link, presence: true

  validate :long_url_must_be_valid

  before_validation :generate_link_code, on: :create

  private

  def long_url_must_be_valid
    if redirect_link.blank?
      errors.add(:redirect_link, 'is required')
    end

    uri = URI.parse(redirect_link)
    unless uri.is_a?(URI::HTTP) && uri.host.present?
      errors.add(:redirect_link, 'must be a valid http or https URL')
    end
  rescue URI::InvalidURIError
    errors.add(:redirect_link, 'must be a valid URL')
  end

  def generate_link_code
    next_id = Snowflake::GeneratorService.new.next_id
    self.link_code = Utils::Base62Service.encode(next_id)
  end
end
