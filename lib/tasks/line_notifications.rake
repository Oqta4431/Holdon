namespace :line_notifications do
  desc "判断対象のアイテムに通知を送信"
  task send_reminders: :environment do
    items = Item.includes(:user, :reminder).ready_for_judgement.merge(Reminder.unnotified_for_current_cycle)

    items.each do |item|
      LineNotificationService.new(item).call
    end
  end
end
