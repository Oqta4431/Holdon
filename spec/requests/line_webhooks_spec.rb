require "rails_helper"

RSpec.describe "LineWebhooks", type: :request do
  describe "POST /line/webhook" do
    let(:webhook_parser) { instance_double(Line::Bot::V2::WebhookParser) }

    before do
      allow(Line::Bot::V2::WebhookParser).to receive(:new).and_return(webhook_parser)
    end

    context "署名が正常な場合" do
      before do
        allow(webhook_parser).to receive(:verify_signature)
      end

      it "200を返す" do
        post "/line/webhook", headers: { "X-Line-Signature" => "valid_signature" }
        expect(response).to have_http_status(:ok)
      end
    end

    context "署名が不正な場合" do
      before do
        allow(webhook_parser).to receive(:verify_signature).and_raise(Line::Bot::V2::WebhookParser::InvalidSignatureError)
      end

      it "400を返す" do
        post "/line/webhook", headers: { "X-Line-Signature" => "invalid_signature" }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
