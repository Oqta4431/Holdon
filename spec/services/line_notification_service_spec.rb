require "rails_helper"

RSpec.describe LineNotificationService do
  let(:user) { create(:user, :line_user) }
  let(:item) { create(:item, user: user) }
  let(:reminder) { create(:reminder, item: item) }
  let(:api_client) { instance_double(Line::Bot::V2::MessagingApi::ApiClient) }

  before do
    allow(Line::Bot::V2::MessagingApi::ApiClient).to receive(:new).and_return(api_client)
  end

  describe "#call" do
    context "providerがlineでないユーザーの場合" do
      let(:non_line_item) { create(:item) }

      it "APIを呼び出さず早期リターンする" do
        expect(api_client).not_to receive(:push_message_with_http_info)
        described_class.new(non_line_item).call
      end
    end

    context "API呼び出しが成功した場合（status 200）" do
      before do
        allow(api_client).to receive(:push_message_with_http_info).and_return([ nil, 200, {} ])
      end

      it "notified_atが更新される" do
        reminder # reminderを事前に生成しておく
        expect {
          described_class.new(item).call
        }.to change { reminder.reload.notified_at }.from(nil)
      end
    end

    context "API呼び出しが失敗した場合（status 200以外）" do
      before do
        allow(api_client).to receive(:push_message_with_http_info).and_return([ nil, 500, {} ])
      end

      it "notified_atが更新されない" do
        reminder
        described_class.new(item).call
        expect(reminder.reload.notified_at).to be_nil
      end
    end

    context "API呼び出しで例外が発生した場合" do
      before do
        allow(api_client).to receive(:push_message_with_http_info).and_raise(StandardError.new("connection error"))
      end

      it "例外を外に伝播させない" do
        reminder
        expect { described_class.new(item).call }.not_to raise_error
      end

      it "notified_atが更新されない" do
        reminder
        described_class.new(item).call
        expect(reminder.reload.notified_at).to be_nil
      end
    end
  end
end
