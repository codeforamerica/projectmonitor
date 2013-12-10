class ProjectsController < ApplicationController
  skip_filter :authenticate_user!, :only => [:show, :status, :index]
  before_filter :load_project, :only => [:edit, :update, :destroy]

  respond_to :json, only: [:index, :show]

  def index
    @projects = Project.displayable
  end

  def new
    @project = Project.new
  end

  def create
    klass = params[:project][:type].present? ? params[:project][:type].constantize : Project
    @project = klass.new(project_params)
    @project.creator = current_user
    if @project.save
      redirect_to edit_configuration_path, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  def show
    respond_with Project.find(params[:id])
  end

  def update
    if params[:password_changed] != 'true'
      params[:project].delete(:auth_password)
    else
      params[:project][:auth_password] = nil unless params[:project][:auth_password].present?
    end

    Project.transaction do
      old_class = @project.class
      if params[:project][:type] && @project.type != params[:project][:type]
        @project = @project.becomes(params[:project][:type].constantize)
        if project = Project.where(id: @project.id)
          project.update_all(type: params[:project][:type])
        end
      end

      if @project.update_attributes(project_params)
        redirect_to edit_configuration_path, notice: 'Project was successfully updated.'
      else
        if project = Project.where(id: @project.id)
          project.update_all(type: old_class.name)
        end
        render :edit
        raise ActiveRecord::Rollback
      end
    end
  end

  def destroy
    @project.destroy
    redirect_to edit_configuration_path, notice: 'Project was successfully destroyed.'
  end

  def validate_build_info
    project = params[:project][:type].constantize.new(project_params)

    if existing_project_missing_password?
      existing_project = Project.find(params[:project][:id])
      project.auth_password = existing_project.auth_password if existing_project
    end

    log_entry = ProjectUpdater.update(project)

    render :json => {
      status: log_entry.status == 'successful',
      error_type: log_entry.error_type,
      error_text: log_entry.error_text.to_s[0,10000]
    }
  end

  private

  def load_project
    @project = Project.find(params[:id])
  end

  def existing_project_missing_password?
    params[:project][:id].present? && params[:project][:auth_password].empty?
  end

  def project_params
    params.require(:project).permit(%i(auth_password auth_username
                                       build_branch code cruise_control_rss_feed_url enabled
                                       jenkins_base_url jenkins_build_name name online
                                       semaphore_api_url tddium_auth_token tddium_project_name
                                       team_city_base_url team_city_build_name travis_github_account
                                       travis_repository type verify_ssl webhooks_enabled
                                       circleci_username circleci_project_name circleci_auth_token repo_name))
  end
end
