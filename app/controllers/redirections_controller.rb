class RedirectionsController < ApplicationController
  before_action :ensure_referrer_is_not_localhost
  before_action :ensure_referrer_is_not_blocked

  def next
    redirection = find_or_create_redirection

    redirect_to redirection.next_url
  end

  def previous
    redirection = find_or_create_redirection

    redirect_to redirection.previous_url
  end

  private

  def find_or_create_redirection
    Redirection.find_by(slug: params[:slug]) ||
      RedirectionCreation.perform(referrer, params[:slug]) ||
      log_headers_and_use_fallback_redirection
  end

  def log_headers_and_use_fallback_redirection
    logger.info "Redirection creation failed. Here are the headers:"
    logger.info http_headers
    Redirection.first
  end

  def referrer
    request.env["HTTP_REFERER"]
  end

  def http_headers
    http_only = ->(key, _) { key.start_with?("HTTP") }
    cookie_header = ->(key, _) { key == "HTTP_COOKIE" }
    request.env.select(&http_only).reject(&cookie_header)
  end

  def ensure_referrer_is_not_localhost
    if HostValidator.new(referrer).invalid?
      redirect_to page_path("localhost")
    end
  end

  def ensure_referrer_is_not_blocked
    if Block.new(referrer).blocked?
      redirect_to Redirection.first.url
    end
  end
end
