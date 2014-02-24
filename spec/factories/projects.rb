FactoryGirl.define do
  factory :project, class: JenkinsProject do
    name { Faker::Name.name }
    code { Faker::Name.name }
    repo_name "project"
    jenkins_base_url "http://www.example.com"
    jenkins_build_name "project"

    factory :jenkins_project
  end

  factory :travis_project, class: TravisProject do
    name { Faker::Name.name }
    code { Faker::Name.name }
    repo_name "project"
    travis_github_account "account"
    travis_repository "project"
  end

  factory :cruise_control_project, class: CruiseControlProject do
    name { Faker::Name.name }
    code { Faker::Name.name }
    repo_name "project"
    cruise_control_rss_feed_url "http://www.example.com/project.rss"
  end

  factory :team_city_project, class: TeamCityProject do
    name { Faker::Name.name }
    code { Faker::Name.name }
    repo_name "project"
    team_city_base_url "foo.bar.com:1234"
    team_city_build_id "bt567"
  end

  factory :team_city_rest_project, class: TeamCityRestProject do
    name { Faker::Name.name }
    code { Faker::Name.name }
    repo_name "project"
    team_city_rest_base_url "example.com"
    team_city_rest_build_type_id "bt456"
  end

  factory :semaphore_project, class: SemaphoreProject do
    name { Faker::Name.name }
    code { Faker::Name.name }
    repo_name "project"
    semaphore_api_url 'https://semaphoreapp.com/api/v1/projects/2fd4e1c67a2d28fced849ee1bb76e7391b93eb12/123/status?auth_token=nyargh'
  end

  factory :tddium_project, class: TddiumProject do
    name { Faker::Name.name }
    code { Faker::Name.name }
    repo_name "project"
    tddium_auth_token 'b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2'
    tddium_project_name 'Test Project A'
  end

  factory :circleci_project, class: CircleCiProject do
    name { Faker::Name.name }
    code { Faker::Name.name }
    repo_name "project"
    circleci_auth_token 'b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2'
    circleci_project_name 'a-project'
    circleci_username 'username'
  end
end
