module Caches; end

class Caches::ReportsStore
  def initialize(report_dir_path: , report_ext:)
    @report_dir_path = report_dir_path
    @report_ext = report_ext
    @store = Concurrent::Atom.new Concurrent::Hash.new
  end

  def update
    # $logger.debug 'start RC update'
    dir_tree = _dir_tree(@report_dir_path, @report_ext)
    # @store.swap do |s|
    #   s.clear
    #   _make_report_store dir_tree, s
    # end
    @store.reset _make_report_store(dir_tree)
    return
  end

  def store
    @store.value
  end

  def content_by(level)
    level_valid?(level) ? store[level][:content] : {}
  end

  def level_valid?(level)
    store.key? level
  end

  def get_back_path(level)
    lvl = level_valid?(level) ? store[level][:backbutton_path] : 'root'
    lvl.empty? ? 'root' : lvl
  end

  def _dir_tree(path, report_ext)
    # List files with filemask
    filemask = "*.#{report_ext}"
    full_filenames = Dir.glob("#{path}#{File::SEPARATOR}**#{File::SEPARATOR}#{filemask}")
    # Remove path from filename
    short_filenames = full_filenames.map(&->(s) { s.gsub("#{path}#{File::SEPARATOR}", '') })
    # Split filenames into array
    # [[dir, subdir, file1], [dir, subdir, file2], ...]
    short_filenames.map(&->(s) { s.split(File::SEPARATOR) })
  end

  def _process_dir_tree_item(item, hash_tree = Concurrent::Hash.new, type = :file)
    return hash_tree if item.empty?
    _hash_tree = Marshal.load(Marshal.dump(hash_tree))

    path = item.size > 1 ? item[0...-1] : ['root']
    path_str = path.join ','
    backbutton_path = path.size > 1 ? path[0...-1] : ['root']
    backbutton_path_str = item.size == 1 ? '' : backbutton_path.join(',')

    _content = _hash_tree.key?(path_str) ? _hash_tree[path_str][:content] : Concurrent::Hash.new
    _hash_tree[path_str] = {
      backbutton_path: backbutton_path_str,
      content: _content.merge!(item.last => type)
    }

    hash_tree.merge _process_dir_tree_item(item[0...-1], _hash_tree, :dir)
  end

  def _make_report_store(lines, store = Concurrent::Hash.new)
    lines.inject(store) { |acc, i| acc = _process_dir_tree_item(i, acc) }
  end
end
