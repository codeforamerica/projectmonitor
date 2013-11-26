require "spec_helper"

describe "Project" do
  describe "/validate_build_info" do
    it "returns log entry" do
      project = FactoryGirl.create(:project)
      ProjectUpdater.stub(:update).and_return(PayloadLogEntry.new(error_text: "Build unsuccessful"))

      post "/projects/validate_build_info", project: project.attributes.merge(auth_password: "password")
      expect(response.body).to match /Build unsuccessful/
    end
  end
end
