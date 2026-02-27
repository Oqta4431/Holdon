require "rails_helper"

RSpec.describe "Authentication", type: :system do
  describe "サインアップ" do
    it "成功するとユーザーが作成され、そのままログイン状態になる" do
      visit new_user_registration_path

      fill_in "お名前", with: "山田 太郎"
      fill_in "メールアドレス", with: "signup@example.com"
      fill_in "パスワード", with: "password123"
      fill_in "パスワード（確認用）", with: "password123"

      expect do
        click_button "サインアップ"
      end.to change(User, :count).by(1)

      expect(page).to have_current_path(root_path)
      expect(page).to have_button("ログアウト")
      expect(page).to have_content("こんにちは！山田 太郎さん")
    end
  end

  describe "ログイン" do
    let!(:user) { create(:user, email: "login@example.com", password: "password123", password_confirmation: "password123", name: "ログイン太郎") }

    it "正しい認証情報で成功する" do
      visit new_user_session_path

      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: "password123"
      click_button "ログイン"

      expect(page).to have_current_path(root_path)
      expect(page).to have_button("ログアウト")
    end

    it "パスワードが間違っていると失敗する" do
      visit new_user_session_path

      fill_in "メールアドレス", with: user.email
      fill_in "パスワード", with: "wrong-password"
      click_button "ログイン"

      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_no_button("ログアウト")
      expect(page).to have_css(".alert")
    end
  end
end
