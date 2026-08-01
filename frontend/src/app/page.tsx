"use client";

import { useEffect, useState } from "react";
import { Product } from "../types/product";

export default function Home() {
  // Railsから取得した商品リストを保存する変数（ステート）
  const [products, setProducts] = useState<Product[]>([]);
  // 読み込み中かどうかを管理するフラグ
  const [loading, setLoading] = useState(true);

  // 画面が表示されたタイミングで1度だけ実行される処理
  useEffect(() => {
    // バックエンド（Rails API）へ商品データをリクエスト
    fetch("http://localhost:3000/api/v1/products")
      .then((res) => res.json())
      .then((data) => {
        setProducts(data); // 届いたデータを保存
        setLoading(false);  // 読み込み完了
      })
      .catch((err) => {
        console.error("API取得エラー:", err);
        setLoading(false);
      });
  }, []);

  // データ読み込み中の表示
  if (loading) {
    return <div className="p-8 text-center">データを読み込み中...</div>;
  }

  // データ読み込み完了後の画面表示
  return (
    <main className="p-8 max-w-2xl mx-auto">
      <h1 className="text-2xl font-bold mb-6 text-center">
        スーパー売れ残り商品通知アプリ (接続テスト)
      </h1>
      
      <div className="space-y-4">
        {products.length === 0 ? (
          <p className="text-gray-500 text-center">商品が見つかりませんでした。</p>
        ) : (
          products.map((product) => (
            <div key={product.id} className="border p-4 rounded-lg shadow-sm bg-white">
              <h2 className="text-xl font-semibold text-gray-800">{product.name}</h2>
              <p className="text-sm text-gray-500 mt-1">店舗: {product.store?.name}</p>
              
              <div className="mt-3 flex items-center space-x-3">
                <span className="line-through text-gray-400">¥{product.original_price}</span>
                <span className="text-red-600 font-bold text-xl">¥{product.discount_price}</span>
              </div>
              
              <div className="mt-2 text-sm text-gray-600">
                残り数量: <span className="font-bold">{product.quantity}</span> 個
              </div>
            </div>
          ))
        )}
      </div>
    </main>
  );
}