require 'settingslogic'
require 'dotenv'

$cur_dir = $root_dir.include?('uri:classloader:') ? File.split($root_dir).first : "#{$root_dir}"
puts "Cur dir: #{$cur_dir}"

cf = File.join($cur_dir, 'config', 'config.yml')
puts "Config File: #{cf}"
unless File.exist? cf
  puts "Error: Not found config file - #{cf}!"
  exit!
end

sf = File.join($cur_dir, 'config', "secrets.env.#{ENV['RUN_ENV']}")
puts "Secrets Env File: #{sf}"
unless File.exist? sf
  puts "Error: Not found secrets file - #{sf}!"
  exit!
end

class Settings < Settingslogic
  namespace ENV['RUN_ENV']
end

Dotenv.load sf

$settings = Settings.new cf