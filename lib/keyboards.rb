module Keyboards
  # module_function
  #
  # def get(level)
  #   _all[level]
  # end
  #
  # # kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: Keyboards::get(:lvl_0))
  # # bot.api.send_message(chat_id: message.chat.id, text: q, reply_markup: kb)
  #
  #
  # def _all
  #   {
  #       # Главное меню
  #       lvl_0: [["Стройка", "Производство"]],
  #       # Стройка
  #       lvl_1_0: [["Боровское шоссе вл2 корп1-1"], ["Боровское шоссе вл2 корп1-2"], ["Боровское шоссе вл2 корп2-1"], ["Боровское шоссе вл2 корп2-2"], ["Назад"]],
  #       # Производство
  #       lvl_1_1: [["Производство. Отчет 1", "Производство. Отчет 2"], ["Назад"]]
  #   }
  # end
end

class Keyboards::Maker
  def initialize(store:, report_ext:)
    @store = store
    @file_ext = report_ext
  end

  def get(level)
    r_index = @file_ext.length + 1 # Plus dot: .htm or .html
    _content = @store.content_by(level).map do |k, v|
      v == :file ? k[0...-r_index] : k
    end

    _content << 'Назад'  if (_content.empty? or level != 'root')
    [_content]
  end
end
