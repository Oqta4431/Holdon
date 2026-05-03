class LineNotificationService
  def initialize(item)
    @item = item
  end

  def call
    return unless @item.user.provider == "line"

    message_text = "まずは一旦テストです。\n商品名：#{@item.name}\nの判断の時間です。\n購入判断はこちらから：(HoldonのURL)"

    push_request = Line::Bot::V2::MessagingApi::PushMessageRequest.new(
      to: @item.user.uid,
      messages: [
        Line::Bot::V2::MessagingApi::TextMessage.new(text: message_text)
      ]
    )

    response, status_code, headers = client.push_message_with_http_info(
      push_message_request: push_request
    )

    @item.reminder.update!(notified_at: Time.current) if status_code == 200

    rescue => e
      Rails.logger.error(e.message)
  end

  private

  def client
    @client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: Rails.application.credentials.dig(:line, :messaging_channel_token)
    )
  end
end
