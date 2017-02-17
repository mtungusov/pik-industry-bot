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
$report_dir_path = $settings.report_dir_path
$report_ext = $settings.report_file_ext

require 'lib/caches'
$RC = Caches::ReportsStore.new(report_dir_path: $report_dir_path, report_ext: $report_ext)
$RC.update

# DEBUG
puts $RC.store

$UC = Caches::UsersStore.new

require 'lib/keyboards'
$KM = Keyboards::Maker.new(store: $RC, report_ext: $report_ext)

require 'lib/reports'
require 'lib/handlers'

Telegram::Bot::Client.run(ENV['TELEGRAM_API_TOKEN'], logger: $logger) do |bot|
  bot.listen do |message|
    Handlers::MessageHandler.new(bot, message).process
  end
end
