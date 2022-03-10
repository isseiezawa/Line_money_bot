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

    if @user.no_name?
      @response = '名前を教えてね'
      @user.catch_name!
    elsif @user.catch_name?
    @response = "#{text}さんだね！\r\n名前覚えたよ。"
      @user.exist_name!
    end

    @response
  end
end
