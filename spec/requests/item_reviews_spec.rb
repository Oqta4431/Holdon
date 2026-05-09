require "rails_helper"

RSpec.describe "Item::Reviews", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:item) { create(:item, user: user) }
  let!(:judgement) { Judgement.create!(item: item, purchase_status: :considering) }
  let!(:reminder) { Reminder.create!(item: item, remind_at: 1.hour.from_now, remind_interval: 3600) }

  describe "GET /items/:item_id/review/new" do
    context "ログイン済み" do
      before { sign_in user }

      context "正常系" do
        it "フォームが表示される" do
          get new_item_review_path(item)

          expect(response).to have_http_status(:ok)
        end
      end

      context "すでにレビュー済みの場合" do
        before { Review.create!(item: item, satisfaction_score: 3) }

        it "ホームにリダイレクトされる" do
          get new_item_review_path(item)

          expect(response).to redirect_to(root_path)
          expect(flash[:error]).to eq("この商品はすでに振り返り済みです")
        end
      end

      context "他ユーザーのアイテムの場合" do
        let(:other_item) { create(:item, user: other_user) }
        let!(:other_judgement) { Judgement.create!(item: other_item, purchase_status: :considering) }
        let!(:other_reminder) { Reminder.create!(item: other_item, remind_at: 1.hour.from_now, remind_interval: 3600) }

        it "404になる" do
          get new_item_review_path(other_item)

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "POST /items/:item_id/review" do
    context "ログイン済み" do
      before { sign_in user }

      context "正常系" do
        it "レビューが保存されホームにリダイレクトされる" do
          post item_review_path(item), params: { review: { satisfaction_score: 4, comment: "満足しています" } }

          expect(response).to redirect_to(root_path)
          expect(item.reload.review.satisfaction_score).to eq(4)
          expect(flash[:success]).to eq("振り返りを保存しました")
        end
      end

      context "すでにレビュー済みの場合" do
        before { Review.create!(item: item, satisfaction_score: 3) }

        it "ホームにリダイレクトされる" do
          post item_review_path(item), params: { review: { satisfaction_score: 4 } }

          expect(response).to redirect_to(root_path)
          expect(flash[:error]).to eq("この商品はすでに振り返り済みです")
        end
      end

      context "satisfaction_score が空の場合" do
        it "保存されず new を再レンダリングする" do
          post item_review_path(item), params: { review: { satisfaction_score: "" } }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(flash[:alert]).to eq("振り返りの保存に失敗しました")
        end
      end

      context "comment が2001文字以上の場合" do
        it "保存されず new を再レンダリングする" do
          post item_review_path(item), params: { review: { satisfaction_score: 3, comment: "a" * 2001 } }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(flash[:alert]).to eq("振り返りの保存に失敗しました")
        end
      end
    end
  end
end
