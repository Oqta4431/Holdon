require "rails_helper"

RSpec.describe "OGP", type: :request do
  describe "GET /" do
    let(:user) { create(:user) }

    before { sign_in user }

    it "OGPメタタグが正しく出力される" do
      get root_path

      expect(response.body).to include("Holdon - 衝動買いを、立ち止まって考える。")
      expect(response.body).to include("欲しいものを登録してリマインドを受け取る。時間をおいて冷静に判断する習慣を、Holdonがサポートします。")
      expect(response.body).to include("Holdon_OGP")
      expect(response.body).to include('content="website"')
      expect(response.body).to include('content="summary_large_image"')
    end
  end
end
