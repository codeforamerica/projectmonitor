class ProjectFeedDecorator < ApplicationDecorator

  def as_json(options = {})
    model.as_json({except: [:auth_username,
                            :auth_password,
                            :deprecated_feed_url,
                            :deprecated_latest_status_id],
                  })
  end

end
