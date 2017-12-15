# TODOS 
desc "Cleansing data"
task :purge_reseed_db => :environment do
  puts "Empty the table.."
  Note.delete_all
  puts "Reseed db.."
  sh "rake db:seed"
  puts ".. done"
end