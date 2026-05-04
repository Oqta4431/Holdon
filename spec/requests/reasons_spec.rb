require "rails_helper"

RSpec.describe "Reasons update", type: :request do
  let(:user) { create(:user) }
  let(:item) { create(:item, user: user) }
  let!(:judgement) { Judgement.create!(item: item, purchase_status: :considering) }
  let!(:reminder) { Reminder.create!(item: item, remind_at: 1.hour.from_now, remind_interval: 3600) }

  describe "ログイン済み" do
    before { sign_in user }

    context "正常系" do
      it "理由を保存し、item の show にリダイレクトされる" do
        patch item_reason_path(item), params: { reason: { purchase_reason: "欲しいから", skip_reason: "" } }

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(item_path(item))
        expect(flash[:success]).to eq("理由を保存しました")
      end
    end

    context "異常系" do
      it "purchase_reason が2000文字超では保存されない" do
        patch item_reason_path(item), params: { reason: { purchase_reason: "a" * 2001, skip_reason: "" } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:error]).to eq("理由を保存できませんでした")
      end
    end
  end
end
