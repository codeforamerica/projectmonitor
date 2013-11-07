class ApplicationController < ActionController::Base
  before_action :allow_iframe_requests

  include IPWhitelistedController
  protect_from_forgery

private

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end
end
