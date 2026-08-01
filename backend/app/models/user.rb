class User < ApplicationRecord
  has_many :notification_logs, dependent: :destroy
end