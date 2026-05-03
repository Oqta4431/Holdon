class LineWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def callback
    body = request.body.read
    signature = request.env["HTTP_X_LINE_SIGNATURE"]

    begin
      webhook_parser.verify_signature(body: body, signature: signature)
      head :ok
    rescue Line::Bot::V2::WebhookParser::InvalidSignatureError
      logger.error "Invalid signature from LINE"
      head :bad_request
    end
  end

  private

  def webhook_parser
    @webhook_parser ||= Line::Bot::V2::WebhookParser.new(
      channel_secret: Rails.application.credentials.dig(:line, :messaging_channel_secret)
    )
  end
end
