class AddNotifiedAtToReminders < ActiveRecord::Migration[7.2]
  def change
    add_column :reminders, :notified_at, :datetime
  end
end
