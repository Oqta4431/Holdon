class AddCategoryIdToItems < ActiveRecord::Migration[7.2]
  def change
    # カテゴリーは任意（null: true）、カテゴリー削除時に item の category_id は null になる
    add_reference :items, :category, null: true, foreign_key: true
  end
end
