# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# テスト用データの初期化
Product.destroy_all
Store.destroy_all
User.destroy_all

# 1. テスト用ユーザーの作成
user = User.create!(
  name: "テスト太郎",
  email: "test@example.com",
  notification_enabled: true
)

# 2. テスト用店舗の作成
store = Store.create!(
  name: "スーパーKIT 広大前店",
  address: "東京都新宿区1-1-1",
  latitude: 35.6895,
  longitude: 139.6917,
  business_hours: "09:00 - 22:00"
)

# 3. テスト用商品の作成
Product.create!([
  {
    store: store,
    name: "特製手作りコロッケ（2個入り）",
    image_url: "https://placehold.co/300x200?text=Croquette",
    original_price: 300,
    discount_price: 150,
    quantity: 5,
    category: "お惣菜",
    sale_end_at: Time.current.end_of_day,
    status: 0 # 0: 出品中
  },
  {
    store: store,
    name: "自家製焼き立て食パン（1斤）",
    image_url: "https://placehold.co/300x200?text=Bread",
    original_price: 280,
    discount_price: 140,
    quantity: 3,
    category: "ベーカリー",
    sale_end_at: Time.current.end_of_day,
    status: 0
  }
])

puts "サンプルデータの作成が完了しました！（ユーザー: 1件, 店舗: 1件, 商品: 2件）"