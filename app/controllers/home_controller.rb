class HomeController < ApplicationController
  layout 'home'

  skip_filter :authenticate_user!

  respond_to :html, :only => [:styleguide]
  respond_to :rss, :only => :builds
  respond_to :json, :only => [:github_status, :heroku_status, :rubygems_status, :index]

  def index
    @projects = Project.displayable.sort_by { |p| p.code.downcase }
  end

  def builds
    @projects = Project.with_statuses
    respond_with @projects
  end

  def github_status
    respond_with ExternalDependency.get_or_fetch('GITHUB')
  end

  def heroku_status
    respond_with ExternalDependency.get_or_fetch('HEROKU')
  end

  def rubygems_status
    respond_with ExternalDependency.get_or_fetch('RUBYGEMS')
  end

  def styleguide
  end
end
