require "rails_helper"
RSpec.describe "Items remind interval", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }

  before { sign_in user }

  describe "create" do
    context "remind_intervalを指定して商品を登録したとき" do
      # 1時間 = 3600秒をリマインド期間として指定
      let(:remind_interval) { 3600 }
      let(:params) do
        { item: { name: "テスト商品", price: 1000, remind_interval: remind_interval } }
      end

      it "remind_intervalが秒単位でreminderに保存される" do
        post items_path, params: params

        created_item = Item.order(:created_at).last
        expect(created_item.reminder.remind_interval).to eq(remind_interval)
      end

      it "remind_atがcreated_at + remind_intervalになっている" do
        post items_path, params: params

        created_item = Item.order(:created_at).last
        expected_remind_at = created_item.created_at + remind_interval.seconds
        expect(created_item.reminder.remind_at).to be_within(1.second).of(expected_remind_at)
      end
    end
  end

  describe "update" do
    let(:item) { create(:item, user: user) }
    # itemファクトリはreminderを自動生成しないため、明示的に作成する
    let!(:reminder) { Reminder.create!(item: item, remind_at: 1.hour.from_now, remind_interval: 3600) }

    context "remind_intervalを変更して保存したとき" do
      # 1日 = 86400秒に変更する
      let(:new_remind_interval) { 86_400 }
      let(:base_time) { Time.zone.parse("2026-03-01 10:00:00") }

      it "remind_intervalが新しい値に更新される" do
        patch item_path(item), params: {
          item: { name: item.name, price: item.price, remind_interval: new_remind_interval }
        }

        expect(reminder.reload.remind_interval).to eq(new_remind_interval)
      end

      it "remind_atがTime.current + remind_intervalに更新される" do
        travel_to(base_time) do
          patch item_path(item), params: {
            item: { name: item.name, price: item.price, remind_interval: new_remind_interval }
          }

          expected_remind_at = base_time + new_remind_interval.seconds
          expect(reminder.reload.remind_at).to be_within(1.second).of(expected_remind_at)
        end
      end
    end
  end
end