require 'concurrent'

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

  def html_report(filename)
    return nil unless File.exist? filename
    clean_filename = File.basename(filename, ".#{$report_ext}")[0..40] + ".#{$report_ext}"
    Faraday::UploadIO.new(filename, 'text/html', clean_filename)
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


# Report Store
# {
#   path: {
#     parent: #root of ARR.to_json,
#     content: [
#       {
#         name: #,
#         dir: # true or false
#       }, ...
#     ]
#     }, ...
# }
#
# Example
# {
#   "dir1,subdir1" => {
#     backbutton_path: "dir1",
#     content: [
#       {name: 'report1.html', type: :file},
#       {name: 'report2.html', type: :file}
#     ]
#   },
#   "dir1" => {
#     backbutton_path: "root",
#     content: [
#       {name: "subdir1", type: :dir}
#     ]
#   },
#   "root" => {
#     content: [
#       {name: "dir1", type: :dir}
#     ]
#   }
# }


# [[dir1, subdir1, file1], [dir1, subdir1, file2], ...]

# def process_dir_tree_item(item, hash_tree = Concurrent::Hash.new, type = :file)
#   return hash_tree if item.empty?
#   _hash_tree = Marshal.load(Marshal.dump(hash_tree))
#
#   path = item.size > 1 ? item[0...-1] : ['root']
#   path_str = path.join ','
#   backbutton_path = path.size > 1 ? path[0...-1] : ['root']
#   backbutton_path_str = item.size == 1 ? '' : backbutton_path.join(',')
#
#   _content = _hash_tree.key?(path_str) ? _hash_tree[path_str][:content] : Set.new
#   _hash_tree[path_str] = {
#     backbutton_path: backbutton_path_str,
#     content: _content << { name: item.last, type: type}
#   }
#
#   hash_tree.merge process_dir_tree_item(item[0...-1], _hash_tree, :dir)
# end
#
#
# def dir_tree(report_dir, filemask)
#   # List files with filemask
#   full_filenames = Dir.glob("#{report_dir}#{File::SEPARATOR}**#{File::SEPARATOR}#{filemask}")
#   # Remove report_dir path from filename
#   short_filenames = full_filenames.map(&->(s) { s.gsub("#{report_dir}#{File::SEPARATOR}", '') })
#   # Split filenames into array
#   # [[dir, subdir, file1], [dir, subdir, file2], ...]
#   short_filenames.map(&->(s) { s.split(File::SEPARATOR) })
# end
#
# def make_report_store(lines)
#   lines.inject(Concurrent::Hash.new) { |acc, i| acc = process_dir_tree_item(i, acc) }
# end
