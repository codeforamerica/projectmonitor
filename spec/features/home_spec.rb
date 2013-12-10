require 'spec_helper'

feature "home" do
  context "when project has only build information" do
    let!(:project) { FactoryGirl.create(:project) }

    before do
      project.statuses << FactoryGirl.build(:project_status, success: true, published_at: 5.days.ago)
    end

    it "should render project collection", js: true do
      visit root_path
      page.should have_selector(".statuses .success")

      page.should have_selector(".time-since-last-build", text: "5d")
      page.should have_content(project.code)
    end
  end
end
