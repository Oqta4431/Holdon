require "rails_helper"

RSpec.describe "Items destroy", type: :request do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let!(:item_a) { create(:item, user: user_a) }
  let!(:item_b) { create(:item, user: user_b) }

  describe "未ログイン" do
    it "DELETE /items/:id はログイン画面にリダイレクトされ、削除されない" do
      expect do
        delete item_path(item_a)
      end.not_to change(Item, :count)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "ログイン済み（userA）" do
    before do
      sign_in user_a
    end

    context "正常系（自分のitem）" do
      it "DELETE /items/:id で Item が1件減り、index にリダイレクトされる" do
        expect do
          delete item_path(item_a)
        end.to change(Item, :count).by(-1)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(items_path)
      end
    end

    context "認可（他ユーザーのitem）" do
      it "DELETE /items/:id は拒否され、対象 item は残る" do
        target_id = item_b.id

        expect do
          delete item_path(item_b)
        end.not_to change(Item, :count)

        expect(response).to have_http_status(:not_found)
        expect(Item.exists?(target_id)).to be(true)
      end
    end

    context "関連レコード削除（dependent: :destroy）" do
      let!(:item_with_associations) { create(:item, user: user_a) }
      let!(:judgement) { Judgement.create!(item: item_with_associations, purchase_status: :considering) }
      let!(:reminder) { Reminder.create!(item: item_with_associations, remind_at: 1.day.from_now, remind_interval: 1) }
      let!(:reason) { Reason.create!(item: item_with_associations, purchase_reason: "買う理由") }

      it "item を削除すると judgement/reminder/reason も削除される" do
        expect do
          delete item_path(item_with_associations)
        end.to change(Item, :count).by(-1)
          .and change(Judgement, :count).by(-1)
          .and change(Reminder, :count).by(-1)
          .and change(Reason, :count).by(-1)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(items_path)
      end
    end
  end
end
