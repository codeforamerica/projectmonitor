require 'spec_helper'

describe ConfigurationController do
  before { sign_in FactoryGirl.create(:user) }

  describe '#index' do
    subject { get :show }

    it 'should return the configuration' do
      ConfigExport.should_receive(:export)
      subject
    end
  end

  describe '#create' do
    subject do
      post :create, content: fixture_file_upload('/files/empty_configuration.yml')
    end

    it 'should change the configuration' do
      ConfigExport.should_receive(:import).with("---\naggregated_projects: []\nprojects: []\n")
      subject
    end
  end

  describe '#edit' do

    it 'should find all the projects' do
      project_scope = double.as_null_object
      Project.should_receive(:order).with(:name).and_return(project_scope)
      get :edit
    end

    it 'should find all the aggregate projects' do
      aggregate_scope = double
      AggregateProject.should_receive(:order).with(:name).and_return(aggregate_scope)
      get :edit
    end
  end
end
