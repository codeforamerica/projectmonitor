class DropTrackerColumns < ActiveRecord::Migration
  def change
    remove_column :projects, :tracker_project_id
    remove_column :projects, :tracker_auth_token
    remove_column :projects, :tracker_validation_status
    remove_column :projects, :tracker_online
  end
end
