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

### 実装の進め方

Planモードでユーザーと合意した内容は確認なしで実装を完走すること。
合意していない想定外の変更が必要な場合は、実装前に必ずユーザーに確認すること。

### コメントの書き方

仕様を知らない第三者が見ても実装の意図が理解できるコメントを残すこと。

- コードの「理由」「背景」「前提」など重要な情報を示す
- 処理の意図を説明し、実装理由を示す
- コードを読めば明らかな内容にはコメントを残さない

### PR日誌の作成

ユーザーから「PR #番号 の日誌を作成して」と指示があった場合、`gh pr view` でPR情報を取得し、`docs/diary/` 配下に日誌ファイルを作成すること。

実装が完了したタイミングで「PRマージ後に『PR #番号 の日誌を作成して』と声をかけてください。」とリマインドすること。

**ファイル名のフォーマット**
```
docs/diary/{日付}_pr{番号}_{ブランチ名}.md
```

例：`docs/diary/2026-03-22_pr129_add-category.md`

---

**diary.md のフォーマット**

1. PR概要（何のためのPRか）
2. 対応した問題・背景
3. 修正・実装内容のポイント
4. 詰まったポイントと解決方法
5. 気づき・振り返り

---

### ドキュメント生成

機能を実装するたびに `docs/` 配下に以下の2ファイルを生成すること。

**ディレクトリ構造**
```
docs/
├── architecture.md
└── {機能名}/
    ├── manual.md
    └── interview.md
```

`docs/` はGitHub非公開のためリポジトリには含まれない（.gitignore管理）。

---

**manual.md（事実）のフォーマット**

1. 機能概要（何をする機能か）
2. DBのテーブル構造とカラムの説明
3. 関係するファイルと役割
4. データの流れ
5. 実装手順
6. 変更したコードと意図（差分と理由）
7. テストの方針・何をテストしているか
8. 使用しているgemとバージョン
9. 環境変数・設定値の一覧
10. 既知の制約・注意点

---

**interview.md（思考）のフォーマット**

1. 一言説明（30秒で説明できる要約）
2. 技術選定の理由
3. 実装上の判断・工夫した点
4. 詰まったポイントと解決方法
5. スケールした場合の懸念点
6. セキュリティ上の考慮点
7. 改善したいと思っている点
8. チーム開発だったらどう設計を変えるか
9. 想定質問と回答