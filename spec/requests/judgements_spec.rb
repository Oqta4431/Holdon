require "rails_helper"

RSpec.describe "Judgements update", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  let(:item) { create(:item, user: user) }
  let!(:judgement) { Judgement.create!(item: item, purchase_status: :considering, decided_at: nil) }
  let!(:reminder) { Reminder.create!(item: item, remind_at: 1.hour.from_now, remind_interval: 60) }

  let(:other_item) { create(:item, user: other_user) }
  let!(:other_judgement) { Judgement.create!(item: other_item, purchase_status: :considering, decided_at: nil) }
  let!(:other_reminder) { Reminder.create!(item: other_item, remind_at: 1.hour.from_now, remind_interval: 60) }

  describe "未ログイン" do
    it "PATCH /items/:item_id/judgement は拒否される" do
      before_state = judgement.reload.attributes.slice("purchase_status", "decided_at")
      before_remind_at = reminder.reload.remind_at

      expect do
        patch item_judgement_path(item), params: { judgement: { purchase_status: :purchased } }
      end.not_to change { judgement.reload.attributes.slice("purchase_status", "decided_at") }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
      expect(reminder.reload.remind_at).to eq(before_remind_at)
      expect(judgement.reload.attributes.slice("purchase_status", "decided_at")).to eq(before_state)
    end

    it "PUT /items/:item_id/judgement は拒否される" do
      before_state = judgement.reload.attributes.slice("purchase_status", "decided_at")
      before_remind_at = reminder.reload.remind_at

      expect do
        put item_judgement_path(item), params: { judgement: { purchase_status: :skipped } }
      end.not_to change { judgement.reload.attributes.slice("purchase_status", "decided_at") }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
      expect(reminder.reload.remind_at).to eq(before_remind_at)
      expect(judgement.reload.attributes.slice("purchase_status", "decided_at")).to eq(before_state)
    end
  end

  describe "ログイン済み" do
    before do
      sign_in user
    end

    context "purchased" do
      it "purchase_status が purchased になり、decided_at が入る" do
        patch item_judgement_path(item), params: { judgement: { purchase_status: :purchased }, redirect_to: judgements_path }

        judgement.reload
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(judgements_path)
        expect(judgement.purchase_status).to eq("purchased")
        expect(judgement.decided_at).not_to be_nil
      end
    end

    context "skipped" do
      it "purchase_status が skipped になり、decided_at が入る" do
        patch item_judgement_path(item), params: { judgement: { purchase_status: :skipped }, redirect_to: judgements_path }

        judgement.reload
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(judgements_path)
        expect(judgement.purchase_status).to eq("skipped")
        expect(judgement.decided_at).not_to be_nil
      end
    end

    context "reconsider（considering）" do
      it "reminder.remind_at が未来へ延長される" do
        base_time = Time.zone.parse("2026-02-28 10:00:00")

        travel_to(base_time) do
          reminder.update!(remind_at: base_time - 1.minute)
          remind_at_before = reminder.reload.remind_at

          patch item_judgement_path(item), params: { judgement: { purchase_status: :considering }, redirect_to: judgements_path }

          judgement.reload
          reminder.reload

          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(judgements_path)
          expect(reminder.remind_at).to be > remind_at_before
          expect(judgement.purchase_status).to eq("considering")
          expect(judgement.decided_at).not_to be_nil
        end
      end
    end

    context "認可（他ユーザーの item）" do
      it "更新できず、DBは変更されない" do
        before_judgement = other_judgement.reload.attributes.slice("purchase_status", "decided_at")
        before_remind_at = other_reminder.reload.remind_at

        patch item_judgement_path(other_item), params: { judgement: { purchase_status: :purchased } }

        expect(response).to have_http_status(:not_found)
        expect(other_judgement.reload.attributes.slice("purchase_status", "decided_at")).to eq(before_judgement)
        expect(other_reminder.reload.remind_at).to eq(before_remind_at)
      end
    end
  end
end
