class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews do |t|
      t.references :item, null: false, foreign_key: true, index: { unique: true }
      t.integer :satisfaction_score, null: false
      t.text :comment
      t.timestamps
    end
  end
end
