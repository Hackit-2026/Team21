class Product < ApplicationRecord
  # 商品は特定の店舗に所属する
  belongs_to :store
  has_many :notification_logs, dependent: :destroy
end