require 'java'

java_import java.lang.System

require 'telegram/bot'

puts "Start App"
puts "Java:  #{System.getProperties["java.runtime.version"]}"
puts "Jruby: #{ENV['RUBY_VERSION']}"

$root_dir = "#{__dir__}"
puts "Dir: #{$root_dir}"

require 'lib/settings'
puts "Namespace: #{Settings.namespace}"
puts "App: #{$settings.app_name}"

$logger = Logger.new($stderr)

require 'lib/keyboards'
require 'lib/reports'

def send_report(bot, chat_id, name)
  q = Reports::get name
  bot.api.send_message(chat_id: chat_id, text: q)
  photo = Reports::photo(name)
  if photo
    bot.api.send_photo(chat_id: chat_id, photo: Reports::photo(name))
  else
    bot.api.send_message(chat_id: chat_id, text: 'Файл не найден!')
  end
end

Telegram::Bot::Client.run($settings.telegram_api_token, logger: $logger) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Привет, #{message.from.first_name}")
      q = 'Выберите группу отчетов:'
      kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: Keyboards::get(:lvl_0))
      bot.api.send_message(chat_id: message.chat.id, text: q, reply_markup: kb)
    when 'Назад'
      q = 'Выберите группу отчетов:'
      kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: Keyboards::get(:lvl_0))
      bot.api.send_message(chat_id: message.chat.id, text: q, reply_markup: kb)
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Пока, #{message.from.first_name}")
    when 'Стройка'
      q = 'Выберите отчет:'
      kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: Keyboards::get(:lvl_1_0))
      bot.api.send_message(chat_id: message.chat.id, text: q, reply_markup: kb)
    when 'Производство'
      q = 'Выберите отчет:'
      kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: Keyboards::get(:lvl_1_1))
      bot.api.send_message(chat_id: message.chat.id, text: q, reply_markup: kb)
    #
    # Отчеты. Стройка
    #
    when 'Боровское шоссе вл2 корп1-1'
      send_report(bot, message.chat.id, message.text)
    when 'Боровское шоссе вл2 корп1-2'
      send_report(bot, message.chat.id, message.text)
    when 'Боровское шоссе вл2 корп2-1'
      send_report(bot, message.chat.id, message.text)
    when 'Боровское шоссе вл2 корп2-2'
      send_report(bot, message.chat.id, message.text)
    #
    # Отчеты. Производство
    #
    when 'Производство. Отчет 1'
      q = Reports::get message.text
      bot.api.send_message(chat_id: message.chat.id, text: q)
    when 'Производство. Отчет 2'
      q = Reports::get message.text
      bot.api.send_message(chat_id: message.chat.id, text: q)
    end
  end
end
