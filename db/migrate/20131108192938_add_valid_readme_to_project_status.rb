class AddValidReadmeToProjectStatus < ActiveRecord::Migration
  def change
    add_column :project_statuses, :valid_readme, :boolean, default: false, null: false
  end
end
