class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :price, null: false
      t.string :url
      t.string :image
      t.text :memo
      t.timestamps
    end
  end
end
