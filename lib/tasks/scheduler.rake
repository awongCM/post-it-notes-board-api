desc "Resetting DB"
task :reset_seeds_db => :environment do
  # - Old
  # puts "Purge and reset database seed..."
  # sh "rake db:reset DISABLE_DATABASE_ENVIRONMENT_CHECK=1"
  # puts "..done."

  # Source - https://www.urbanbound.com/make/how-to-reset-heroku-databases-with-scheduler
  # raise "Cannot run this task in production" if Rails.env.production?

  puts "Dropping all tables (except migrations table)"
  ActiveRecord::Base.connection.tables.each do |table|
    if table != 'schema_migrations'
      query = "DROP TABLE IF EXISTS #{table} CASCADE;"
      ActiveRecord::Base.connection.execute(query)
    end
  end

  puts "Do db schema load and re-seed..."
  sh "db:schema:load"
  sh "db:seed"
  puts "done."
end
