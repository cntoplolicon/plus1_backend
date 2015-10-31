class AppRelease < ActiveRecord::Base
  default_scope { order(version_code: :desc) }
end
