require "rails_helper"

RSpec.describe "Profiles update", type: :request do
  let(:user) { create(:user) }

  describe "未ログイン" do
    it "PATCH /profile はログイン画面にリダイレクトされ、更新されない" do
      expect do
        patch profile_path, params: { user: { name: "変更後" } }
      end.not_to change { user.reload.name }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "ログイン済み" do
    before { sign_in user }

    context "正常系" do
      it "有効な名前で更新でき、show にリダイレクトされる" do
        patch profile_path, params: { user: { name: "新しい名前" } }

        expect(user.reload.name).to eq("新しい名前")
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(profile_path)
      end
    end

    context "異常系" do
      it "名前が空だと更新されない" do
        original_name = user.name

        patch profile_path, params: { user: { name: "" } }

        expect(user.reload.name).to eq(original_name)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).not_to be_redirect
      end

      it "名前が21文字以上だと更新されない" do
        original_name = user.name

        patch profile_path, params: { user: { name: "あ" * 21 } }

        expect(user.reload.name).to eq(original_name)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).not_to be_redirect
      end
    end
  end
end
