class LinksController < ApplicationController
  def generate_short_url
    mapping = LinkMapping.new(redirect_link: params[:long_url])

    if mapping.save
      render json: { short_url: link_url(mapping.link_code) }, status: :created
    else
      render json: { error: mapping.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    mapping = LinkMapping.find_by(link_code: params[:id])

    if mapping
      # explicitly set the status to found (302) to indicate a temporary redirect and
      # not a permanent redirect to account for visits to the short URL
      redirect_to mapping.redirect_link, status: :found, allow_other_host: true
    else
      head :not_found
    end
  end
end
