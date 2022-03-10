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
        t = text.split(/[[:blank:]]/)
        if t[0] == '収入'
          @user.moneys.create(name: t[0], yen: t[1].gsub(/[^\d]/, "").to_i)
          @response = "#{@user.name}様\r\n#{t[0]}\r\n金額：#{t[1]}\r\n入金ID：#{@user.moneys.last.id}\r\n\r\n保存しました！"
        else
          @user.moneys.create(name: t[0], yen: t[1].gsub(/[^\d]/, "").to_i * -1)
          @response = "#{@user.name}様\r\n出金：#{t[0]}\r\n金額：#{t[1]}\r\n支出ID：#{@user.moneys.last.id}\r\n\r\n保存しました！"
        end
      end

      case text
      when '日収支'
        hash = @user.moneys.group("EXTRACT(year FROM created_at), EXTRACT(month FROM created_at), EXTRACT(day FROM created_at)").sum(:yen)
        @response = "#{@user.name}様　日にちごとの収支\r\n"
        hash.each do |date, value|
          @response << "#{date.to_i}日分…#{value}円\r\n"
        end
      when '月収支'
        hash = @user.moneys.group("EXTRACT(year FROM created_at), EXTRACT(month FROM created_at)").sum(:yen)
        @response = "#{@user.name}様　月ごとの収支\r\n"
        hash.each do |date, value|
          @response << "#{date.to_i}月分…#{value}円\r\n"
        end
      when '全収支'
        @response = "#{@user.name}様の全収支です\r\n"
        @user.moneys.each do |money|
          @response << "#{money.created_at.month}月|#{money.name}…#{money.yen}円\r\n"
        end
      when '収支大爆発'
        @user.moneys.destroy_all
        @response = "#{@user.name}様の収支が消滅しました。\r\n\\|ﾎﾞｶｰﾝ|//"
      end
    end

    @response
  end
end
