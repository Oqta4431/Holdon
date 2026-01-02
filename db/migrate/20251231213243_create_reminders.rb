class CreateReminders < ActiveRecord::Migration[7.2]
  def change
    create_table :reminders do |t|
      t.references :item, null: false, foreign_key: true, index: { unique: true }

      ## remind_at = decided_at + remind_interval
      t.datetime :remind_at

      ## 単位は「sec」24h = 86_400sec
      t.integer :remind_interval

      t.timestamps
    end
  end
end
