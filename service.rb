require 'java'
# require 'pry'

java_import java.lang.System

require 'telegram/bot'

puts "Start App"
puts "Java:  #{System.getProperties["java.runtime.version"]}"
puts "Jruby: #{ENV['RUBY_VERSION']}"

# $root_dir = "#{__dir__}"
$root_dir = ENV["PWD"]
puts "Dir: #{$root_dir}"

require 'lib/settings'
puts "Namespace: #{Settings.namespace}"
puts "App: #{$settings.app_name}"

$logger = Logger.new($stderr)
$report_dir_path = $settings.report_dir_path
$report_ext = $settings.report_file_ext

require 'lib/caches'
$RC = Caches::ReportsStore.new(report_dir_path: $report_dir_path, report_ext: $report_ext)
$UC = Caches::UsersStore.new
# binding.pry

require 'lib/keyboards'
$KM = Keyboards::Maker.new(store: $RC, report_ext: $report_ext)

require 'lib/reports'
require 'lib/handlers'

require 'thread'
Thread.abort_on_exception = true

Thread.new do
  while true do
    $RC.update
    # DEBUG
    # $logger.debug $RC.store.to_s
    sleep $settings.period_report_dir_update
  end
end

Telegram::Bot::Client.run(ENV['TELEGRAM_API_TOKEN'], logger: $logger) do |bot|
  bot.listen do |message|
    Handlers::MessageHandler.new(bot, message).process
  end
end
