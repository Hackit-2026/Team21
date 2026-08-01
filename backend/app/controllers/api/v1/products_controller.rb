module Api
  module V1
    class ProductsController < ApplicationController
      # GET /api/v1/products
      def index
        # 店舗情報も含めて商品一覧を取得
        products = Product.includes(:store).all
        render json: products, include: :store
      end
    end
  end
end