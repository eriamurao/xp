class LinkMapping < ApplicationRecord
  validates :link_code, presence: true, uniqueness: true
  validates :redirect_link, presence: true

  validate :long_url_must_be_valid

  before_validation :generate_link_code, on: :create

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
    next_id = Snowflake::GeneratorService.new.next_id
    self.link_code = Utils::Base62Service.encode(next_id)
  end
end
