desc "This task is called by the Heroku scheduler add-on"
task :reset_seeds_db => :environment do
  puts "Purge and reset database seed..."
  sh "rake db:reset DISABLE_DATABASE_ENVIRONMENT_CHECK=1"
  puts "..done."
end
