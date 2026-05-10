class ReviewLineNotificationService
  def initialize(user)
    @user = user
  end

  def call
    return unless @user.provider == "line"

    items = @user.items.ready_for_review
    return if items.empty?

    item_lines = items.map do |item|
      label = item.judgement.purchased? ? "購入" : "見送り"
      "・#{item.name} ： #{label}"
    end.join("\n")

    message_text = <<~TEXT
      📊 先週の振り返りです

      あなたは#{items.count}件の買い物を熟考しました。

      #{item_lines}

      あの時の決断、今の自分はどう感じていますか？
      少しだけ時間をとって、記録してみましょう。

      ▶ 振り返りはこちら：holdon-app.com
    TEXT

    push_request = Line::Bot::V2::MessagingApi::PushMessageRequest.new(
      to: @user.uid,
      messages: [
        Line::Bot::V2::MessagingApi::TextMessage.new(text: message_text)
      ]
    )

    client.push_message_with_http_info(
      push_message_request: push_request
    )

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
