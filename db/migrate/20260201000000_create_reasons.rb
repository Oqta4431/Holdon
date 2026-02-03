class CreateReasons < ActiveRecord::Migration[7.1]
  def change
    create_table :reasons do |t|
      t.references :item, null: false, foreign_key: true, index: { unique: true }
      t.text :purchase_reason
      t.text :skip_reason

      t.timestamps
    end
  end
end
