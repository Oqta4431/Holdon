class CreateReminders < ActiveRecord::Migration[7.2]
  def change
    create_table :reminders do |t|
      t.timestamps
    end
  end
end
