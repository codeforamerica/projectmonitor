#
# Asynchronous IO (via the Reactor model) can be a little confusing, so a bit
# of an explanation is in order:
#
# This poller basically looks for all projects that need updating, then asks
# the project to build a workload, which is a list of jobs that need to be
# completed. A job is essentially a URL that needs to be fetched.
#
# When the complete list of jobs has been completed, the handler is notified and
# the project is updated. The workload model is used as jobs can be completed
# in any order.
#
class ProjectPoller

  def initialize
    @workloads = {}
    @poll_period = 60
    @connection_timeout = 45
    @inactivity_timeout = 30
    @max_follow_redirects = 10
    @pending = 0
  end

  def run
    @run_once = false

    EM.run do
      EM.add_periodic_timer(@poll_period) do
        poll_projects
      end
    end
  end

  def run_once
    @run_once = true

    EM.run do
      poll_projects
    end
  end

  def stop
    EM.stop_event_loop
  end

  private

  def poll_projects
    Project.updateable.find_each do |project|
      workload = find_or_create_workload(project, project.handler)

      workload.unfinished_job_descriptions.each do |job_id, description|
        request = create_ci_request(project, description)
        add_workload_handlers(project, workload, job_id, request)
      end
    end
  end

  def create_ci_request(project, url)
    get_options = {}
    if project.auth_username.present?
      get_options[:head] = {'authorization' => [project.auth_username, project.auth_password]}
    end
    if project.accept_mime_types.present?
      headers = get_options[:head] || {}
      get_options[:head] = headers.merge("Accept" => project.accept_mime_types)
    end

    create_request(url, get_options)
  end

  def create_request(url, options = {})
    url = "http://#{url}" unless /\A\S+:\/\// === url
    connection = EM::HttpRequest.new url, connect_timeout: @connection_timeout, inactivity_timeout: @inactivity_timeout

    get_options = {redirects: @max_follow_redirects}.merge(options)
    connection.get get_options
  end

  def add_workload_handlers(project, workload, job_id, request)
    begin_workload

    request.callback do |client|
      workload.store(job_id, client.response)
      remove_workload(project) if workload.complete?
      finish_workload
    end

    request.errback do |client|
      workload.failed(client.error)
      remove_workload(project)
      finish_workload
    end
  end

  def find_or_create_workload(project, handler)
    @workloads[project] ||= PollerWorkload.new(handler)
  end

  def remove_workload(project)
    @workloads.delete(project)
  end

  def begin_workload
    @pending += 1
  end

  def finish_workload
    @pending -= 1
    stop if @run_once && @pending.zero?
  end

end
