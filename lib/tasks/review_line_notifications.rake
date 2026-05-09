namespace :review_line_notifications do
  desc "判断レビュー対象のアイテムをユーザーに通知"
  task send_review_reminders: :environment do
    items = Item.includes(:user, :review).ready_for_review
    users = items.map { |item| item.user }.uniq

    users.each do |user|
      ReviewLineNotificationService.new(user).call
    end
  end
end
