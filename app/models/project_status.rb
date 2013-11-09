class ProjectStatus < ActiveRecord::Base

  belongs_to :project

  validates :success, inclusion: { in: [true, false] }
  validates :valid_readme, inclusion: { in: [true, false] }
  validates :build_id, presence: true

  class << self

    def recent(projects, limit)
      where(project_id: Array(projects).map(&:id)).
        reverse_chronological.
        limit(limit)
    end

    def reverse_chronological
      where('build_id IS NOT NULL').
        order('published_at DESC, build_id DESC')
    end

    def latest
      reverse_chronological.first
    end

    def green
      where(success: true)
    end

    def red
      where(success: false)
    end

  end

  def as_json(options={})
    super(only: [:success, :url], root: false)
  end

  def in_words
    if success?
      'success'
    else
      'failure'
    end
  end

  def readme_valid_in_words
    if valid_readme
      'Readme Valid'
    else
      'Readme Broke'
    end
  end

end
