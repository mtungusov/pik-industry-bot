require "settingslogic"

$cur_dir = $root_dir.include?('uri:classloader:') ? File.split($root_dir).first : "#{$root_dir}"
puts "Cur dir: #{$cur_dir}"
cf = "#{$cur_dir}/config/config.yml"
puts "Config File: #{cf}"
unless File.exist? cf
  puts "Error: Not found config file - #{cf}!"
  exit!
end

class Settings < Settingslogic
  namespace ENV['RUN_ENV']
end
$settings = Settings.new cf
