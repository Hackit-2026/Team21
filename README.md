# cirkit-b
### データベースのセットアップ手順 (backend フォルダ内)
```bash
# データベースの作成とマイグレーション実行
bin/rails db:create db:migrate

# サンプル（テスト）データの投入
bin/rails db:seed

## Phase 1 動作確認手順

### 1. バックエンドの起動
```bash
cd backend
bin/rails db:create db:migrate db:seed
bin/rails server