作成したリポジトリはこちらになります
https://github.com/gnubow/cirkit-b

# :ショッピングカート: スーパー売れ残り商品通知アプリ (MVP) - バックエンド API & 設計仕様書

スーパー店舗の売れ残り（値引き）商品を近隣消費者にリアルタイム通知し、フードロス削減を目指すWebアプリケーションのバックエンド（Ruby on Rails API）リポジトリです。

---

## :クリップボード: 目次
1. [システム概要 & 技術スタック](#1-システム概要--技術スタック)
2. [データモデル設計 (ER図・テーブル定義)](#2-データモデル設計-er図テーブル定義)
3. [API 仕様書 (エンドポイント一覧)](#3-api-仕様書-エンドポイント一覧)
4. [環境構築 & ローカル起動手順](#4-環境構築--ローカル起動手順)
5. [curl による全 API テスト手順](#5-curl-による全-api-テスト手順)
6. [ディレクトリ構造](#6-ディレクトリ構造)

---

## 1. システム概要 & 技術スタック

### :ダーツ: 目的・特徴
- **フードロス削減**: 店舗側で値引きした商品を登録し、通知を希望する消費者のスマホ（Web Push）へ即時配信します。
- **シンプル設計**: MVP（最小限の製品）として、ユーザー認証や複雑な決済を省き、閲覧・登録・通知トリガーに特化しています。

### :ハンマーとレンチ: 技術スタック
- **バックエンド**: Ruby on Rails 7.x (API Mode)
- **データベース**: PostgreSQL / SQLite (開発環境)
- **フロントエンド（連携先）**: Next.js (TypeScript, PWA対応)
- **通知機能（予定）**: Firebase Cloud Messaging (FCM) / Web Push API

---

## 2. データモデル設計 (ER図・テーブル定義)

### :線グラフ: データモデル概要

```text
[ Store ] 1 --- * [ Product ]
   |
   | (将来用)
   *
[ User ] 1 --- * [ NotificationLog ] * --- 1 [ Product ]
```

### :ファイルキャビネット: 主要テーブル定義

#### `stores` (店舗)
| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| `id` | integer | PRIMARY KEY | 店舗ID |
| `name` | string | NOT NULL | 店舗名（例: スーパータナカ 渋谷本店） |
| `address` | string | | 住所 |
| `latitude` | float | | 緯度（位置情報検索用） |
| `longitude` | float | | 経度（位置情報検索用） |
| `business_hours` | string | | 営業時間 |
| `created_at / updated_at` | datetime | NOT NULL | タイムスタンプ |

#### `products` (商品)
| カラム名 | 型 | 制約 | 説明 |
|---|---|---|---|
| `id` | integer | PRIMARY KEY | 商品ID |
| `store_id` | integer | FOREIGN KEY, NOT NULL | 店舗ID |
| `name` | string | NOT NULL | 商品名 |
| `image_url` | string | | 商品画像URL |
| `original_price` | integer | NOT NULL | 定価 (円) |
| `discount_price` | integer | NOT NULL | 値引き後価格 (円) |
| `quantity` | integer | NOT NULL, DEFAULT 1 | 残り数量 |
| `category` | string | NOT NULL | カテゴリ（惣菜、精肉、鮮魚など） |
| `sale_end_at` | datetime | | セール終了日時 |
| `status` | integer/enum | NOT NULL, DEFAULT 0 | 状態 (`on_sale`: 販売中, `sold_out`: 完売) |
| `created_at / updated_at` | datetime | NOT NULL | タイムスタンプ |

> :電球: **モデルで定義済みのロジック・メソッド**:
> - `discount_percentage`: 定価と値引き価格から割引率（%）を自動計算（ゼロ除算防止対応済み）。
> - `expired?`: 販売終了日時（`sale_end_at`）を過ぎているか判定。
> - **バリデーション**: `discount_price` は必ず `original_price` より安い金額であることを強制。

#### `users` (ユーザー - 今後利用)
| カラム名 | 型 | 説明 |
|---|---|---|
| `id` | integer | ユーザーID |
| `name` | string | ユーザー名 |
| `email` | string | メールアドレス |
| `notification_enabled` | boolean | 通知受け取りフラグ (デフォルト: true) |

#### `notification_logs` (通知履歴 - 今後利用)
| カラム名 | 型 | 説明 |
|---|---|---|
| `id` | integer | 履歴ID |
| `user_id` | integer | 送信先ユーザーID |
| `product_id` | integer | 対象商品ID |
| `sent_at` | datetime | 送信日時 |

---

## 3. API 仕様書 (エンドポイント一覧)

ベースURL: `http://localhost:3000/api/v1`

| 機能 | HTTPメソッド | エンドポイント | リクエストパラメータ例 | レスポンス期待値 |
|---|---|---|---|---|
| **商品一覧取得** | `GET` | `/products` | なし | `200 OK`: 販売中の商品配列 (JSON) |
| **商品詳細取得** | `GET` | `/products/:id` | なし | `200 OK`: 商品オブジェクト<br>`404 Not Found`: 見つからない場合 |
| **新規商品登録** | `POST` | `/products` | `{"product": {...}}` | `201 Created`: 作成済み商品データ<br>`422 Unprocessable Entity`: バリデーションエラー |
| **商品情報更新** | `PUT` | `/products/:id` | `{"product": {...}}` | `200 OK`: 更新後の商品データ<br>`422 Unprocessable Entity`: エラー |
| **商品削除** | `DELETE` | `/products/:id` | なし | `204 No Content`: レスポンスボディなし |

---

## 4. 環境構築 & ローカル起動手順

初心者開発者でも以下のコマンド順で簡単に動作環境をセットアップできます。

### 1. リポジトリのクローン & 移動
```bash
git clone <repository-url>
cd backend
```

### 2. ライブラリのインストール
```bash
bundle install
```

### 3. データベースのセットアップ & シードデータ投入
```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```
> :電球: `db/seeds.rb` にはテスト用店舗（スーパータナカ）および動作確認用の商品サンプルデータが定義されています。

### 4. Rails サーバーの起動
```bash
bin/rails server
```
サーバーが `http://localhost:3000` で起動したら準備完了です！

---

## 5. curl による全 API テスト手順

ターミナルを開き、以下のコマンドを実行して各APIの動作を確認できます。

### ① 商品一覧取得 (GET)
```bash
curl -X GET http://localhost:3000/api/v1/products
```

### ② 商品詳細取得 (GET)
```bash
curl -X GET http://localhost:3000/api/v1/products/1
```

### ③ 新規商品登録 (POST - 正常系)
```bash
curl -X POST http://localhost:3000/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{
    "product": {
      "name": "特製ローストビーフ丼",
      "image_url": "https://example.com/roastbeef.jpg",
      "original_price": 980,
      "discount_price": 490,
      "quantity": 3,
      "category": "惣菜",
      "sale_end_at": "2026-08-01T21:00:00Z",
      "status": "on_sale"
    }
  }'
```

### ④ 新規商品登録 (POST - バリデーションエラー検証)
割引価格を定価より高く設定して送信すると、422エラーが返ります。
```bash
curl -X POST http://localhost:3000/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{
    "product": {
      "name": "エラーテスト商品",
      "original_price": 500,
      "discount_price": 1000,
      "quantity": 1,
      "category": "惣菜"
    }
  }'
```

### ⑤ 商品情報の更新 (PUT)
```bash
curl -X PUT http://localhost:3000/api/v1/products/1 \
  -H "Content-Type: application/json" \
  -d '{
    "product": {
      "discount_price": 400,
      "quantity": 10
    }
  }'
```

### ⑥ 商品の削除 (DELETE)
```bash
curl -i -X DELETE http://localhost:3000/api/v1/products/1
```
> ※ `HTTP/1.1 204 No Content` が返れば成功です。

### ⑦ 削除後の確認 (404 Not Found 検証)
削除したIDをリクエストし、エラーハンドリングが機能しているか確認します。
```bash
curl -X GET http://localhost:3000/api/v1/products/1
```
> レスポンス: `{"error":"指定された商品が見つかりません"}`

---

## 6. ディレクトリ構造

```text
backend/
├── app/
│   ├── controllers/
│   │   └── api/
│   │       └── v1/
│   │           └── products_controller.rb  # 商品一覧・詳細・登録・更新・削除コントローラー
│   └── models/
│       ├── store.rb                        # 店舗モデル
│       └── product.rb                      # 商品モデル (バリデーション・割引率計算ロジック)
├── config/
│   ├── initializers/
│   │   └── cors.rb                         # Next.jsとのCORS通信許可設定
│   └── routes.rb                           # APIルーティング (/api/v1/products)
├── db/
│   ├── migrate/                            # マイグレーションファイル
│   └── seeds.rb                            # 動作確認用サンプルデータ
└── README.md                               # 本ドキュメント
```

---

# :ラップトップ: フロントエンド実装状況 (Next.js)

`frontend` フォルダ側でここまでに実装した内容のまとめです。

## 技術スタック

- Next.js 16 (App Router, Turbopack) / React 19 / TypeScript
- Tailwind CSS 4(店舗管理画面) + 独自CSS `app/products/products.css`(消費者向け画面)
- `next/font/google`(Geist, Geist Mono, M PLUS Rounded 1c, Noto Sans JP)
- Web Push API(ブラウザ通知)

追加のnpmパッケージは入れておらず、`create-next-app` 標準構成のままです。

## セットアップ

`frontend/.env.local`:
```
NEXT_PUBLIC_API_BASE_URL=http://localhost:3000
NEXT_PUBLIC_VAPID_PUBLIC_KEY=(backendで生成したVAPID公開鍵)
```

VAPID公開鍵は `bin/rails runner "key = Webpush.generate_key; puts key.public_key; puts key.private_key"` で生成し、公開鍵をフロントの `.env.local`、秘密鍵をバックエンド起動時の環境変数(`VAPID_PRIVATE_KEY`)に設定します。

```bash
cd frontend
npm install
npm run dev
```
バックエンド(`bin/rails server`)を先に起動しておくと、フロントは自動的に3001番などにポートがずれます。

## ページ構成

### 消費者向け

| パス | 内容 |
|---|---|
| `/` | `/products` へリダイレクト |
| `/products` | 商品一覧。検索・カテゴリ絞り込み・並び替え・プッシュ通知の登録ボタン |
| `/products/[id]` | 商品詳細ページ |

### 店舗向け(管理画面)

| パス | 内容 |
|---|---|
| `/store/products` | 商品一覧(全ステータス)・編集リンク・削除ボタン |
| `/store/products/new` | 新規商品登録フォーム(画像はファイル選択→Base64変換で送信) |
| `/store/products/[id]/edit` | 商品編集フォーム(価格・個数・ステータス・画像を変更可能) |

> :警告: 店舗管理画面には認証がありません。バックエンド側のログイン機能が未完成のため、URLを知っていれば誰でも商品の登録・編集・削除ができる状態です。

## 主なディレクトリ

```text
frontend/
├── app/
│   ├── page.tsx                          # / → /products リダイレクト
│   ├── products/
│   │   ├── page.tsx                      # 一覧ページ(サーバーコンポーネント)
│   │   ├── ProductsPageClient.tsx        # 検索・絞り込み・通知登録(クライアント)
│   │   ├── products.css                  # 消費者向け画面のスタイル
│   │   └── [id]/page.tsx                 # 詳細ページ
│   └── store/products/
│       ├── page.tsx                      # 管理: 一覧・削除
│       ├── new/page.tsx                  # 管理: 新規登録
│       └── [id]/edit/page.tsx            # 管理: 編集
├── components/
│   └── ProductDetailContent.tsx          # 商品詳細の中身(詳細ページ共通)
├── lib/
│   ├── api.ts                            # バックエンドAPIクライアント
│   ├── format.ts                         # カテゴリ絵文字・残り時間・割引バッジの整形
│   └── push.ts                           # プッシュ通知の購読処理
├── types/
│   └── product.ts                        # Product / Store の型定義
└── public/
    └── sw.js                             # Service Worker(プッシュ通知受信)
```

## 実装済み機能

- 商品一覧・詳細の表示(バックエンドAPI連携、`store` ネスト対応済み)
- 検索・カテゴリ絞り込み・並び替え(販売終了が近い順/割引率順/価格順)
- レスポンシブ対応(PC・スマホ両方の画面幅)
- 店舗による商品の新規登録・編集・削除
- 消費者側のプッシュ通知購読(「通知を受け取る」ボタン → ブラウザ通知許可 → `POST /api/v1/subscriptions`)

## 未実装・保留中

- **店舗側の「通知を送信する」ボタン(F-13)**: バックエンドの `POST /api/v1/products/:id/notify` は実装済みだが、フロントの送信ボタンは未着手
- **新着商品が出た時の音通知**: 一度着手したが保留中
- **お気に入り(気になる)機能・通知設定パネル**: スコープ外として保留
- **ログイン機能**: バックエンドのDevise実装が未完成のため、フロント連携は未着手
- **店舗の認証・own判定**: 「どの店舗としてログインしているか」の概念がバックエンドに無いため、管理画面に認証がない

## 既知の制約

- 画像アップロードは実際のファイルストレージではなく、Base64データU
