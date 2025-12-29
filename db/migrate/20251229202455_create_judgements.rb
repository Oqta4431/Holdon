class CreateJudgements < ActiveRecord::Migration[7.2]
  def change
    create_table :judgements do |t|
      t.references :item, null: false, foreign_key: true, index: { unique: true }
      t.integer :purchase_status, null: false
      t.datetime :decided_at
      t.timestamps
    end
  end
end
