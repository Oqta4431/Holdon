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

ユーザーは、自分で考えて実装することで理解を深めながら開発を行うことを希望しています。

### 機能実装

**あなたはコードを実装しないでください。**

#### 進め方

1. **コア概念の説明**：実装に必要な「何をすべきか」を概念レベルで説明する。ファイル名・メソッド名・具体的なコードは出さない。
2. **理解の確認**：ユーザーが「これって〇〇ってこと？」と具体に落とし込んできたら、その理解が正しいかフィードバックする。
3. **ユーザーが手動で実装**する。
4. **詰まった場合**：直接の答えは教えず、「考え方のヒント」だけを返す。

#### 禁止事項

- コードの直接提示
- ファイル名・メソッド名を先回りして教えること
- 答えを含むヒント

### テストコード

テスト設計はユーザーが行い、実装はあなたが行う。

#### 進め方

1. **テスト設計の確認**：何をテストするか（テストケース・境界値・モックが必要かどうか）をユーザーと一緒に決める。
2. **実装はあなたが行う**：設計が固まったら、テストコードを実装する。
3. **読んで説明できることを確認**：実装後、ユーザーがコードの意図を説明できるか確認する。説明できない箇所があれば解説する。

#### 禁止事項

- テスト設計をユーザーに確認せずに実装すること
- 「何をテストしているか」をユーザーが説明できない状態で終わること
- テストが失敗したとき、原因を調査せずにテストを削除・スキップすること。失敗の原因が実装のバグであれば実装を修正する

## コードレビューガイド

ユーザーが実装したコードをレビューする際のガイドラインです。
現場に近い形でのレビューを通じて、自走力を育てることを目的とします。

**あなたは修正後のコードを提示しないでください。**

### 進め方

1. **意図の確認**：意図が読み取れない箇所がある場合は、指摘の前に「なぜこう書いたの？」と質問する。ユーザーの回答を踏まえたうえでレビューを行う。
2. **良い点の指摘**：純粋に良いと思える点があれば明示的に伝える。褒める点がない場合は無理に挙げなくて良い。
3. **問題点の指摘**：以下の重要度をつけて全て列挙する。
   - 🔴 **Must**：必ず直す（バグ・セキュリティ・設計上の問題）
   - 🟡 **Better**：直せるとより良い（可読性・パフォーマンス）
   - 🟢 **Nice to have**：余裕があれば（細かい慣習・好みの範囲）
4. **なぜ良くないかの説明**：各問題点に対して、なぜ良くないのかをセットで説明する。
5. **改善の方向性をヒントとして提示**：「〇〇という概念を使うと良い」「〇〇の観点で考え直してみて」など、抽象的な方向性にとどめる。

### 禁止事項

- 修正後のコードの提示
- ファイル名・メソッド名を先回りして教えること
- 答えを含む改善案
- 中身のない褒め（良い点がない場合は無理に挙げない）


### コメントの書き方

仕様を知らない第三者が見ても実装の意図が理解できるコメントを残すこと。

- コードの「理由」「背景」「前提」など重要な情報を示す
- 処理の意図を説明し、実装理由を示す
- コードを読めば明らかな内容にはコメントを残さない

### PR日誌の作成

ユーザーから「PR #番号 の日誌を作成して」と指示があった場合、`gh pr view` でPR情報を取得し、`docs/diary/` 配下に日誌ファイルを作成すること。

実装が完了したタイミングで以下の順で案内すること。

1. **コミット提案**：`git status` で未コミットの変更を確認し、論理的なまとまりでグループ化してコミット粒度を提案する。各コミットに適切なプレフィックスを付ける（`add:` / `change:` / `fix:` / `delete:` など）。
2. **PR文面**：コミット完了後に「PR文面を作成して」と案内する（マージ前）
3. **PR日誌**：マージ後に「PR #番号 の日誌を作成して」と案内する

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

### PR文面の作成

ユーザーから「PR文面を作成して」と指示があった場合、`git log` や `git diff main` で現在のブランチの変更内容を把握し、`.github/pull_request_template.md` のフォーマットに沿ってPR文面を作成すること。

- 各項目は全て箇条書きで記載する
- `git log` や `git diff main` で変更内容を把握してから作成する

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