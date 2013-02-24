require 'rubygems'
require 'rufus-scheduler'

scheduler = Rufus::Scheduler.start_new
# scheduler.every '10s' do
#   puts "Start scheduler"
#   Archive.add_spends_to_archive
#   puts "End scheduler"
# end
scheduler.cron '0 21 * * 1-5' do
  puts "Start scheduler"
  Archive.add_spends_to_archive
  puts "End scheduler"
end