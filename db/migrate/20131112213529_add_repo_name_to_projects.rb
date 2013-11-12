class AddRepoNameToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :repo_name, :string
  end
end
