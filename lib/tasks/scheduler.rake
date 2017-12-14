desc "This task is called by the Heroku scheduler add-on"
task :reset_seeds_db => :environment do
  puts "Purge and reset database seed..."
  sh "rake db:reset"
  puts "..done."
end
