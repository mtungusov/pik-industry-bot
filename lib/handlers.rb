module Handlers
  class MessageHandler
    def initialize(bot, message)
      @bot = bot
      @message = message
      @user = message.from.id
      @chat = message.chat.id
    end

    def process
      # Get level
      @level = _get_level

      case @message.text
      when 'Назад'
        process_back_btn
      else
        process_btn
      end
    end

    def process_btn
      if _is_report_file? @message.text
        process_report_file
      else
        process_level_btn
      end
    end

    def process_back_btn
      old_level = @level
      @level = _get_back_level
      _set_level
      # msg = "BackBtn! Level from #{old_level} to #{@level}"
      msg = 'Выберите раздел или отчет'
      @bot.api.send_message(chat_id: @chat, text: msg, reply_markup: _get_kb)
    end

    def process_level_btn
      old_level = @level
      @level = old_level == 'root' ? @message.text : [old_level, @message.text].join(',')
      _set_level
      # msg = "Btn! Level from #{old_level} to #{@level}"
      msg = 'Выберите раздел или отчет'
      @bot.api.send_message(chat_id: @chat, text: msg, reply_markup: _get_kb)
    end

    def process_report_file
      filename = "#{@message.text}.#{$report_ext}"
      path = @level.split(',').join(File::SEPARATOR)
      fullpath = "#{$report_dir_path}#{File::SEPARATOR}#{path}#{File::SEPARATOR}#{filename}"
      $logger.debug fullpath

      report_file = Reports::html_report fullpath
      if report_file
        @bot.api.send_document(chat_id: @chat, document: report_file)
      else
        @bot.api.send_message(chat_id: @chat, text: "File не найден! Level: #{@level}")
      end
    end

    def _get_level
      level = $UC.get @user
      _level_valid?(level) ? level : 'root'
    end

    def _get_back_level
      $RC.get_back_path @level
    end

    def _set_level
      $UC.set @user, @level
    end

    def _level_valid?(level)
      $RC.level_valid? level
    end

    def _get_kb
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: $KM.get(@level))
    end

    def _is_report_file?(command)
      content = $RC.content_by @level
      key = "#{command}.#{$report_ext}"
      content.key?(key) and (content[key] == :file)
    end
  end
end

# def send_report(bot, chat_id, name)
#   q = Reports::get name
#   bot.api.send_message(chat_id: chat_id, text: q)
#   photo = Reports::photo(name)
#   if photo
#     bot.api.send_photo(chat_id: chat_id, photo: Reports::photo(name))
#   else
#     bot.api.send_message(chat_id: chat_id, text: 'Файл не найден!')
#   end
# end

#     when 'Боровское шоссе вл2 корп1-1'
#       # send_report(bot, message.chat.id, message.text)
#       filename = "#{$cur_dir}/files/test.htm"
#       bot.api.send_document(chat_id: message.chat.id, document: Faraday::UploadIO.new(filename, 'text/html'))
