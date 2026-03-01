# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

衝動買いを抑制する自己管理アプリ。商品を登録後、一定時間（開発環境: 5秒、本番予定: 24時間）が経過してから「購入 / 見送り / 再検討」を判定させることで、熟考した購買行動を促す。

## よく使うコマンド

### 開発サーバー起動
```bash
docker compose up
```

### テスト実行
```bash
# 全テスト
docker compose exec web bundle exec rspec

# 特定のファイル
docker compose exec web bundle exec rspec spec/requests/items_create_spec.rb

# 特定のexample（行番号指定）
docker compose exec web bundle exec rspec spec/requests/items_create_spec.rb:10
```

### コード品質チェック
```bash
docker compose exec web bundle exec rubocop          # Lintチェック
docker compose exec web bundle exec rubocop -a       # 自動修正
docker compose exec web bundle exec brakeman -q      # セキュリティチェック
```

### アセットビルド
```bash
docker compose exec web bundle exec rails tailwindcss:build
docker compose exec web bundle exec rails javascript:build
```

### DB操作
```bash
docker compose exec web bin/rails db:prepare         # DB作成 + マイグレーション
docker compose exec web bin/rails db:migrate
docker compose exec web bin/rails db:rollback
```

## アーキテクチャ概要

### ドメインモデルの関係
```
User
 └── Item (has_many)
       ├── Judgement (has_one) - 購入判定ステータス
       ├── Reminder  (has_one) - リマインド時刻
       └── Reason    (has_one) - 購入/見送り理由メモ
```

Item作成時に Judgement・Reminder が自動生成される（`ItemsController#create`）。

### 判定フロー
1. `Item.ready_for_judgement` スコープ（`remind_at <= 現在時刻` かつ `considering` 状態）で判定対象を抽出
2. `JudgementsController#index` で対象1件を表示
3. `JudgementsController#update` で3択の選択を処理
   - `purchased` / `skipped`: 判定終了、`decided_at` に時刻を記録
   - `considering`（再検討）: `remind_at` を `Time.current + REMIND_INTERVAL` に延長

### リマインド間隔の設定
`config/initializers/remind_settings.rb` で `REMIND_INTERVAL` 定数を定義。現在は開発・本番ともに5秒（MVP用短縮値）。本番リリース時に変更予定。

### フロントエンド構成
- Hotwire（Turbo + Stimulus）で SPA的な操作感を実現
- `app/javascript/controllers/flip_controller.js`: 判定画面のカード表裏切り替えアニメーション
- CSS: Tailwind CSS v4 + daisyUI v5 (`app/assets/stylesheets/application.css`)
- JSビルド: esbuild（`npm run build` 相当を `rails javascript:build` で実行）

### 認証・認可
- Deviseによるメール＋パスワード認証
- 全コントローラーで `authenticate_user!` を使用
- 他ユーザーのリソースへのアクセスは `current_user.items.find(id)` パターンで防止

## テスト構成

- **フレームワーク**: RSpec（`spec/requests/` にリクエストスペック, `spec/system/` にシステムスペック）
- **テストデータ**: FactoryBot（`spec/factories/`）+ Faker
- **ブラウザテスト**: Capybara + Selenium
- **ヘルパー設定**: `spec/support/devise.rb`（Deviseテストヘルパー）、`spec/support/factory_bot.rb`

テスト用画像は `spec/fixtures/files/` に配置。

## CI/CD

GitHub Actions（`.github/workflows/ci.yml`）で以下を順に実行:
1. `rubocop` - Lintチェック
2. `brakeman` - セキュリティチェック（現在 `continue-on-error: true`、解決後に削除予定）
3. `rspec` - テスト（PostgreSQL 15サービス付き、Tailwind/JSビルドも含む）
4. Render へのデプロイ（mainブランチへのpushまたは手動実行時のみ）

## 既知のTODO・注意点

- `items/show.html.erb` にデバッグ用コードあり（PR前に削除すること）
- `posts#index` がルートパス（`/`）の仮実装。本来は `home#index` に差し替え予定
- Brakemanの警告が残存（CI で `continue-on-error: true` 中）
- カテゴリ機能はビュー上で「未実装」として表示されているのみ

## 出力ガイド
ユーザーは、写経して学習しながら開発を行うことを希望しています。
＊*あなたはコードを教えるだけで実装しないでください。**
まず現在のファイルを一緒に確認してから、変更箇所を順番に教えていきます。各変更箇所ごとに：
- 変更後のコードを提示
- なぜこう変更するのかを説明
という流れで進めてください。

実装を行う際に「仕様を知らない第三者が見ても一目で実装の意図が理解できるコメントを残すこと」を心がけてください。
具体的には以下の点に留意してください。
- コードの「理由」、「背景」、「前提」等の重要な情報が示されている
   - 処理の意図を説明し、実装理由を示すこと
   - 変数やメソッドなどのオブジェクトは構造を説明すること
- 今の自分のためではなく、未来の自分、チームのメンバーのために書かれている
   - コードを読めば簡単に理解できる内容はコメントを残さないこと