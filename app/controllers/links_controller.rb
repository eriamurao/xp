class LinksController < ApplicationController
  def generate_short_url
    mapping = LinkMapping.new(redirect_link: params[:long_url])

    if mapping.save
      render json: { short_url: link_url(mapping.link_code) }, status: :created
    else
      render json: { error: mapping.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Important: Since allow_other_host: true is triggers a warning in Brakeman.
  #   Since this is an intentional open redirect, we should ignore the warning.
  #   When updating this code, make sure to update the fingerprint in config/brakeman.ignore.
  #   Run `bin/rails brakeman:sync_ignore` to update the ignore file.
  def show
    mapping = LinkMapping.find_by(link_code: params[:id])
    link_url = mapping&.safe_redirect_link

    if link_url
      # explicitly set the status to found (302) to indicate a temporary redirect and
      # not a permanent redirect to account for visits to the short URL
      redirect_to link_url, status: :found, allow_other_host: true
    else
      head :not_found
    end
  end
end
