FactoryGirl.define do
  factory :project_status do
    success { [true, false].sample }
    build_id { rand(1000) }
    valid_readme false
  end
end
