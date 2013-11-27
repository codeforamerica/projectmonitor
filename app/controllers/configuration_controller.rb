class ConfigurationController < ApplicationController
  before_filter :authenticate_user!

  respond_to :text, only: :show

  def show
    headers['Content-Type'] = 'text/plain'
    headers['Content-Disposition'] = %{attachment; filename="configuration.yml"}
    headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
    render text: ConfigExport.export
  end

  def create
    ConfigExport.import params[:content].read
    head :ok
  end

  def edit
    @projects = Project.order(:name)
    @aggregate_projects = AggregateProject.order(:name)
  end

end
