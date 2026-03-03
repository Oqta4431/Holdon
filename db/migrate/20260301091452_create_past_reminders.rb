class CreatePastReminders < ActiveRecord::Migration[7.2]
  def change
    create_table :past_reminders do |t|
      # remindersテーブルとの外部キー制約：Reminderが削除されたらPastReminderも連鎖削除される
      t.references :reminder, null: false, foreign_key: true

      # 再検討前の remind_at を履歴として保存する
      t.datetime :past_remind_at, null: false

      t.timestamps
    end
  end
end
