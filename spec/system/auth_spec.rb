require "rails_helper"

RSpec.describe "User", type: :system do
  context '未サインアップの場合' do
    it 'ユーザーが増えること' do
      visit root_path
      expect {
        visit user_line_omniauth_callback_path
    }.to change(User, :count).by(1)
    end
  end

  context 'サインアップ済みの場合' do
    before do
      User.create!(
        email: 'test@example.com',
        name: 'test',
        provider: 'line',
        uid: '000000',
        password: 'test@example.com'
      )
    end

    it 'ユーザーは増えないこと' do
      visit root_path
      expect {
        visit user_line_omniauth_callback_path
    }.to_not change(User, :count)
    end
  end
end
