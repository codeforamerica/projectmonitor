module ConfigExport
  PROJECT_ATTRIBUTES = %w[guid
                          name
                          deprecated_feed_url
                          auth_username
                          auth_password
                          enabled
                          type
                          polling_interval
                          deprecated_latest_status_id
                          code
                          cruise_control_rss_feed_url
                          jenkins_base_url
                          jenkins_build_name
                          team_city_base_url
                          team_city_build_id
                          team_city_rest_base_url
                          team_city_rest_build_type_id
                          travis_github_account
                          travis_repository
                          webhooks_enabled]
  class << self
    def export
      projects = Project.all.map do |project|
        exported_project_attributes(project)
      end

      {'projects' => projects}.to_yaml
    end

    def import(config)
      config = YAML.load(config)

      Project.transaction do
        cached_agg = {}

        config['projects'].each do |project_attributes|
          guid = project_attributes['guid']

          model_class = project_attributes['type'].constantize
          project = if guid.present?
                      model_class.where(guid: guid).first_or_initialize
                    else
                      model_class.new
                    end

          project_attributes.each do |key, value|
            setter_method = "#{key}="
            project.send(setter_method, value) if project.respond_to?(setter_method)
          end
          project.save(validate: false)
        end
      end
    end

    private

    def exported_project_attributes(project)
      project.attributes.slice(*PROJECT_ATTRIBUTES)
    end
  end

end
