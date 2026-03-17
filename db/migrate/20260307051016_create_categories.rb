class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end

    # 同一ユーザー内でカテゴリー名が重複しないようにユニーク制約を追加
    # DBレベルで保証することでモデルバリデーションをすり抜けた場合も防止できる
    add_index :categories, [ :user_id, :name ], unique: true
  end
end
