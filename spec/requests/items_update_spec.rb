require "rails_helper"

RSpec.describe "Items update", type: :request do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:item_a) { create(:item, user: user_a, name: "Before A", price: 1000, url: "https://before-a.example.com", memo: "before memo a") }
  let(:item_b) { create(:item, user: user_b, name: "Before B", price: 2000, url: "https://before-b.example.com", memo: "before memo b") }

  describe "未ログイン" do
    it "GET /items/:id/edit はログイン画面にリダイレクトされる" do
      get edit_item_path(item_a)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "PATCH /items/:id はログイン画面にリダイレクトされ、更新されない" do
      expect do
        patch item_path(item_a), params: { item: { name: "Changed", price: 9999 } }
      end.not_to change { item_a.reload.attributes.slice("name", "price", "url", "memo") }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "PUT /items/:id はログイン画面にリダイレクトされ、更新されない" do
      expect do
        put item_path(item_a), params: { item: { name: "Changed", price: 9999 } }
      end.not_to change { item_a.reload.attributes.slice("name", "price", "url", "memo") }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "ログイン済み（userA）" do
    before do
      sign_in user_a
    end

    context "正常系（自分のitem）" do
      let(:valid_params) do
        {
          item: {
            name: "Updated Name",
            price: 34_567,
            url: "https://example.com/updated",
            memo: "updated memo"
          }
        }
      end

      it "PATCH /items/:id で更新され、show にリダイレクトされる" do
        patch item_path(item_a), params: valid_params

        item_a.reload
        expect(item_a.name).to eq("Updated Name")
        expect(item_a.price).to eq(34_567)
        expect(item_a.url).to eq("https://example.com/updated")
        expect(item_a.memo).to eq("updated memo")
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(item_path(item_a))
        expect(flash[:success]).to eq("商品を編集しました")
      end
    end

    context "異常系（自分のitem）" do
      it "name が空だと更新されない" do
        original = item_a.attributes.slice("name", "price", "url", "memo")

        patch item_path(item_a), params: { item: { name: "", price: item_a.price, url: item_a.url, memo: item_a.memo } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).not_to be_redirect

        item_a.reload
        expect(item_a.name).to eq(original["name"])
      end

      it "price が空だと更新されない" do
        original = item_a.attributes.slice("name", "price", "url", "memo")

        patch item_path(item_a), params: { item: { name: item_a.name, price: nil, url: item_a.url, memo: item_a.memo } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).not_to be_redirect

        item_a.reload
        expect(item_a.price).to eq(original["price"])
      end
    end

    context "認可（他ユーザーのitem）" do
      it "GET /items/:id/edit は拒否される" do
        get edit_item_path(item_b)

        expect(response).to have_http_status(:not_found)
      end

      it "PATCH /items/:id は拒否され、itemは変更されない" do
        original = item_b.attributes.slice("name", "price", "url", "memo")

        patch item_path(item_b), params: { item: { name: "Hacked", price: 1, url: "https://hacked.example.com", memo: "hacked" } }

        expect(response).to have_http_status(:not_found)
        expect(item_b.reload.attributes.slice("name", "price", "url", "memo")).to eq(original)
      end
    end
  end
end
