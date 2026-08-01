class Store < ApplicationRecord
  # 店舗は複数の商品を所有する
  has_many :products, dependent: :destroy
end