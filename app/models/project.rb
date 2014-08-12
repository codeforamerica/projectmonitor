class Project < ActiveRecord::Base

  RECENT_STATUS_COUNT = 8
  DEFAULT_POLLING_INTERVAL = 30
  MAX_STATUS = 15

  has_many :statuses,
    class_name: 'ProjectStatus',
    dependent: :destroy,
    before_add: :update_refreshed_at,
    after_add: :remove_outdated_status
  has_many :payload_log_entries
  belongs_to :creator, class_name: "User"

  serialize :last_ten_velocities, Array
  serialize :iteration_story_state_counts, JSON

  scope :enabled, -> { where(enabled: true) }
  scope :with_statuses, -> { joins(:statuses).uniq }

  scope :updateable, -> {
    enabled
    .where(webhooks_enabled: [nil, false])
  }

  scope :displayable, lambda {
    enabled.order('code ASC')
  }

  validates :name, presence: true
  validates :type, presence: true

  before_create :generate_guid

  attr_writer :feed_url

  def self.project_specific_attributes
    columns.map(&:name).grep(/#{project_attribute_prefix}_/)
  end

  def self.content_exists?(readme)
    readme.match(/^#+.+/).present?
  end

  def self.installation_instructions_exists?(readme)
    readme.match(/\bInstall(ation|ing)?\b|\bBuild(ing)?\b|\bSetup\b|\bDeploy(ing|ment)?\b/).present?
  end

  def self.relocated_section_exists?(readme)
    readme.match(/Repository has moved/i).present?
  end

  def has_valid_readme?
    account = travis_github_account.present? ? travis_github_account : "codeforamerica"
    response_json = get("repos/#{account}/#{repo_name}/readme")
    readme = Base64.decode64(response_json["content"])
    Project.content_exists?(readme) &&
    (Project.installation_instructions_exists?(readme) ||
     Project.relocated_section_exists?(readme) ||
     created_at > 1.week.ago)
  end

  def code
    super.presence || name.downcase.gsub(" ", '')[0..3]
  end

  def latest_status
    statuses.latest
  end

  def recent_statuses(count = RECENT_STATUS_COUNT)
    ProjectStatus.recent(self, count)
  end

  def status
    latest_status || ProjectStatus.new(project: self)
  end

  def green?
    online? && status.success? && status.valid_readme?
  end

  def yellow?
    online? && !red? && !green?
  end

  def red?
    online? && (latest_status.try(:success?) == false || latest_status.try(:valid_readme?) == false)
  end

  def status_in_words
    if red?
      'failure'
    elsif green?
      'success'
    elsif yellow?
      'indeterminate'
    else
      'offline'
    end
  end

  def color
    return "white" unless online?
    return "green" if green?
    return "red" if red?
    return "yellow" if yellow?
  end

  def red_since
    breaking_build.try(:published_at)
  end

  def red_build_count
    return 0 if breaking_build.nil? || !online?
    statuses.where(success: false).where("id >= ?", breaking_build.id).count
  end

  def feed_url
    raise NotImplementedError, "Must implement feed_url in subclasses"
  end

  def build_status_url
    raise NotImplementedError, "Must implement build_status_url in subclasses"
  end

  def to_s
    name
  end

  def building?
    super
  end

  def current_build_url
  end

  def last_green
    @last_green ||= recent_statuses.green.first
  end

  def breaking_build
    @breaking_build ||= if last_green.nil?
                          recent_statuses.red.last
                        else
                          recent_statuses.red.where(["build_id > ?", last_green.build_id]).first
                        end
  end

  def has_auth?
    auth_username.present? || auth_password.present?
  end

  def payload
    raise NotImplementedError, "Must implement payload in subclasses"
  end

  def has_status?(status)
    statuses.where(build_id: status.build_id).any?
  end

  def has_dependencies?
    false
  end

  def generate_guid
    self.guid = SecureRandom.uuid
  end

  def volatility
    if last_ten_velocities.any?
      calculated_volatility
    else
      0
    end
  end

  def handler
    ProjectWorkloadHandler.new(self)
  end

  def published_at
    latest_status.try(:published_at)
  end

  def accept_mime_types
    nil
  end

  private

  def calculated_volatility
    sample_volatility.round(0)
  end

  def sample_volatility
    mean = last_ten_velocities.mean
    std_dev = last_ten_velocities.standard_deviation
    vol = (std_dev * 100.0) / mean
    vol.nan? ? 0 : vol
  end

  def self.project_attribute_prefix
    name.match(/(.*)Project/)[1].underscore
  end

  def update_refreshed_at(status)
    self.last_refreshed_at = Time.now if online?
  end

  def remove_outdated_status(status)
    if statuses.count > MAX_STATUS
      keepers = statuses.order('created_at DESC').limit(MAX_STATUS)
      ProjectStatus.delete_all(["project_id = ? AND id not in (?)", id, keepers]) if keepers.any?
    end
  end

  def fetch_statuses
    Delayed::Job.enqueue(StatusFetcher::Job.new(self), priority: 0)
  end

  def simple_statuses
    statuses.map(&:success)
  end

  def url_with_scheme url
    if url =~ %r{\Ahttps?://}
      url
    else
      "http://#{url}"
    end
  end

  def get(path)
    uri = URI.join("https://api.github.com/", path)
    response = nil
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPOK)
      JSON.parse response.body
    else
      response.error!
    end
  end
end
