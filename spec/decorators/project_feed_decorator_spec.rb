require 'spec_helper'

describe ProjectFeedDecorator do

  describe "#as_json" do
    subject { ProjectFeedDecorator.new(Project.new(name: "foo")).as_json.keys }

    it { should include "tag_list" }
    it { should_not include %w[auth_username auth_password deprecated_feed_url deprecated_latest_status_id] }
  end

end
