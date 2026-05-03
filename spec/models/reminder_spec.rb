require "rails_helper"
RSpec.describe Reminder, type: :model do

  describe "unnotified_for_current_cycle" do
    context "notified_atとremind_atの比較" do
      it "notified_at IS NULLの時は判断対象に含む" do
        reminder = create(:reminder, notified_at: nil)
        expect(Reminder.unnotified_for_current_cycle).to include(reminder)
      end

      it "notified_at < remind_atの時は含む" do
        reminder = create(:reminder, notified_at: 30.minutes.from_now)
        expect(Reminder.unnotified_for_current_cycle).to include(reminder)
      end

      it "notified_at > remind_atの時は含まない" do
        reminder = create(:reminder, notified_at: 2.hours.from_now)
        expect(Reminder.unnotified_for_current_cycle).not_to include(reminder)
      end

      it "notified_at = remind_atの時は含まない" do
        remind_time = 1.hour.from_now
        reminder = create(:reminder, remind_at: remind_time, notified_at: remind_time)
        expect(Reminder.unnotified_for_current_cycle).not_to include(reminder)
      end
    end
  end

end
