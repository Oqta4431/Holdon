require "rails_helper"

RSpec.describe "Pages", type: :request do
  describe "GET /" do
    context "未ログイン" do
      it "200 OK で閲覧できる" do
        get root_path

        expect(response).to have_http_status(:ok)
      end
    end

    context "ログイン済み" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "home_path にリダイレクトされる" do
        get root_path

        expect(response).to redirect_to(home_path)
      end
    end
  end

  describe "GET /terms" do
    context "未ログイン" do
      it "200 OK で閲覧できる" do
        get terms_path

        expect(response).to have_http_status(:ok)
      end
    end

    context "ログイン済み" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "200 OK で閲覧できる" do
        get terms_path

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /privacy" do
    context "未ログイン" do
      it "200 OK で閲覧できる" do
        get privacy_path

        expect(response).to have_http_status(:ok)
      end
    end

    context "ログイン済み" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "200 OK で閲覧できる" do
        get privacy_path

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
