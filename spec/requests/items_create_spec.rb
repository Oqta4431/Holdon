require "rails_helper"

RSpec.describe "Items create", type: :request do
  describe "未ログイン" do
    it "GET /items/new はログイン画面にリダイレクトされる" do
      get new_item_path

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "POST /items はログイン画面にリダイレクトされる" do
      expect do
        post items_path, params: { item: { name: "未ログイン商品", price: 1000 } }
      end.not_to change(Item, :count)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "ログイン済み" do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    context "正常系" do
      let(:valid_params) do
        { item: { name: "iPad", price: 120_000, remind_interval: 3600 } }
      end

      it "POST /items で Item が作成され、current_user に紐づき、index にリダイレクトされる" do
        expect do
          post items_path, params: valid_params
        end.to change(Item, :count).by(1)

        created_item = Item.order(:created_at).last
        expect(created_item.user_id).to eq(user.id)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(items_path)
      end
    end

    context "異常系" do
      it "name なしでは作成されない" do
        expect do
          post items_path, params: { item: { name: "", price: 120_000 } }
        end.not_to change(Item, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).not_to redirect_to(items_path)
      end

      it "price なしでは作成されない" do
        expect do
          post items_path, params: { item: { name: "iPad", price: nil } }
        end.not_to change(Item, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).not_to redirect_to(items_path)
      end
    end
  end
end
