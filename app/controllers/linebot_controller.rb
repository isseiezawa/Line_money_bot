class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text

          main_action(event)

          message = {
            type: 'text',
            text: @response
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end

  private

  def main_action(event)

    @user = User.find_or_create_by(line_id: event['source']['userId'])
    text = event.message['text']

    case @user.name_status
    when 'no_name'
      @response = '名前を教えてね'
      @user.catch_name!
    when 'catch_name'
      @response = "#{text}さんだね！\r\n名前覚えたよ。"
      @user.update(name: text)
      @user.exist_name!
    when 'exist_name'
      if text.end_with?('円')
        t = text.split
        @user.moneys.create(name: t[0], yen: t[1].gsub(/[^\d]/, "").to_i)
        @response = "何に使ったか：#{t[0]}\r\n金額：#{t[1]}\r\n保存したよ！"
      end
    end

    @response
  end
end
