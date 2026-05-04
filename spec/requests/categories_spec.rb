require "rails_helper"

RSpec.describe "Categories", type: :request do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let!(:category_a) { create(:category, user: user_a) }
  let!(:category_b) { create(:category, user: user_b) }

  describe "未ログイン" do
    it "GET /categories/modal はログイン画面にリダイレクトされる" do
      get modal_categories_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "GET /categories はログイン画面にリダイレクトされる" do
      get categories_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "GET /categories/new はログイン画面にリダイレクトされる" do
      get new_category_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "POST /categories はログイン画面にリダイレクトされ、作成されない" do
      expect do
        post categories_path, params: { category: { name: "テスト" } }
      end.not_to change(Category, :count)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "DELETE /categories/:id はログイン画面にリダイレクトされ、削除されない" do
      expect do
        delete category_path(category_a)
      end.not_to change(Category, :count)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "ログイン済み（user_a）" do
    before { sign_in user_a }

    describe "GET /categories/modal" do
      it "200 を返す" do
        get modal_categories_path
        expect(response).to have_http_status(:ok)
      end

      it "自分のカテゴリーのみ表示される" do
        get modal_categories_path
        expect(response.body).to include(category_a.name)
        expect(response.body).not_to include(category_b.name)
      end
    end

    describe "GET /categories" do
      it "200 を返す" do
        get categories_path
        expect(response).to have_http_status(:ok)
      end

      it "自分のカテゴリーのみ表示される" do
        get categories_path
        expect(response.body).to include(category_a.name)
        expect(response.body).not_to include(category_b.name)
      end
    end

    describe "GET /categories/new" do
      it "200 を返す" do
        get new_category_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /categories" do
      context "正常系" do
        let(:valid_params) { { category: { name: "ファッション" }, return_to: new_item_path } }

        it "Category が作成され、current_user に紐づく" do
          expect do
            post categories_path, params: valid_params
          end.to change(Category, :count).by(1)

          expect(Category.last.user_id).to eq(user_a.id)
        end

        it "return_to に selected_category_id を付与してリダイレクトされる" do
          post categories_path, params: valid_params

          created_category = Category.last
          expect(response).to redirect_to("#{new_item_path}?selected_category_id=#{created_category.id}")
          expect(flash[:success]).to eq("カテゴリーを作成しました")
        end

        it "return_to が不正なURLの場合は items_path にリダイレクトされる" do
          post categories_path, params: { category: { name: "ファッション" }, return_to: "https://evil.com" }
          expect(response).to redirect_to(items_path)
        end
      end

      context "異常系" do
        it "name なしでは作成されない" do
          expect do
            post categories_path, params: { category: { name: "" } }
          end.not_to change(Category, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(flash[:error]).to eq("カテゴリーを作成出来ませんでした")
        end

        it "name が30文字超では作成されない" do
          expect do
            post categories_path, params: { category: { name: "a" * 31 } }
          end.not_to change(Category, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(flash[:error]).to eq("カテゴリーを作成出来ませんでした")
        end

        it "同一ユーザー内で name が重複する場合は作成されない" do
          expect do
            post categories_path, params: { category: { name: category_a.name } }
          end.not_to change(Category, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(flash[:error]).to eq("カテゴリーを作成出来ませんでした")
        end
      end
    end

    describe "DELETE /categories/:id" do
      context "正常系（自分のカテゴリー）" do
        it "Category が削除され、categories_path にリダイレクトされる" do
          expect do
            delete category_path(category_a)
          end.to change(Category, :count).by(-1)

          expect(response).to redirect_to(categories_path)
          expect(flash[:success]).to eq("カテゴリーを削除しました")
        end

        it "削除されたカテゴリーに紐づく Item の category_id が NULL になる" do
          item = create(:item, user: user_a, category: category_a)

          delete category_path(category_a)

          expect(item.reload.category_id).to be_nil
        end
      end

      context "認可（他ユーザーのカテゴリー）" do
        it "404 が返り、削除されない" do
          expect do
            delete category_path(category_b)
          end.not_to change(Category, :count)

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
