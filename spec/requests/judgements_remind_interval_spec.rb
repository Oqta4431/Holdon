require "rails_helper"

RSpec.describe "Judgements remind interval", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let(:item) { create(:item, user: user) }
  # judgementとreminderはitemファクトリが自動生成しないため明示的に作成する
  let!(:judgement) { Judgement.create!(item: item, purchase_status: :considering, decided_at: nil) }
  let!(:reminder) { Reminder.create!(item: item, remind_at: 1.hour.ago, remind_interval: 3600) }

  before { sign_in user }

  describe "再検討（considering）" do
    context "remind_intervalを指定して再検討したとき" do
      # 2時間 = 7200秒を新しいリマインド期間として指定
      let(:remind_interval) { 7200 }
      let(:base_time) { Time.zone.parse("2026-03-01 10:00:00") }

      it "remind_atがdecided_at + remind_intervalに更新される" do
        travel_to(base_time) do
          patch item_judgement_path(item), params: {
            judgement: { purchase_status: :considering, remind_interval: remind_interval },
            redirect_to: judgements_path
          }

          judgement.reload
          reminder.reload
          expected_remind_at = judgement.decided_at + remind_interval.seconds
          expect(reminder.remind_at).to be_within(1.second).of(expected_remind_at)
        end
      end

      it "再検討前のremind_atがpast_remindersに1件保存される" do
        # travel_toの外で取得しないと、travel_to内でremind_atが変わってしまう
        old_remind_at = reminder.remind_at

        travel_to(base_time) do
          patch item_judgement_path(item), params: {
            judgement: { purchase_status: :considering, remind_interval: remind_interval },
            redirect_to: judgements_path
          }

          expect(reminder.past_reminders.count).to eq(1)
          expect(reminder.past_reminders.last.past_remind_at).to be_within(1.second).of(old_remind_at)
        end
      end
    end
  end
end