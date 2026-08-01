// 店舗情報の型定義
export interface Store {
  id: number;
  name: string;
  address: string;
}

// 商品情報の型定義
export interface Product {
  id: number;
  name: string;
  image_url: string;
  original_price: number;
  discount_price: number;
  quantity: number;
  category: string;
  store: Store;
}