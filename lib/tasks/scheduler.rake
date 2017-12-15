# TODOS 
desc "Cleansing data"
task :purge_reseed_db => :environment do
  puts "Empty the table.."
  Note.delete_all

  puts "Reset primary key sequences.."
  # For SQLlite
  # update_seq_sql = "update sqlite_sequence set seq = 0 where name = 'notes';"
  # ActiveRecord::Base.connection.execute(update_seq_sql)
  # For Postgres
  ActiveRecord::Base.connection.reset_pk_sequence!('notes')

  puts "Reseed db.."
  sh "rake db:seed"
  puts ".. done"
end