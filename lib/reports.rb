module Reports
  module_function

  def get(name)
    # "Отчет не найден" unless _all.include? name
    "Показать: #{name}"
  end

  def photo(name)
    filename = "#{$cur_dir}/files/#{name}.jpeg"
    return nil unless File.exist? filename
    Faraday::UploadIO.new(filename, 'image/jpeg')
  end
end
