desc "This task is called by the Heroku scheduler add-on"
task :reset_seeds_db => :environment do
  puts "Purge and reset database seed..."
  run_command("run rake db:reset")
  run_command("run rake db:seed")
  puts "..done."
end
