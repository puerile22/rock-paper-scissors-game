require 'active_record'
require 'active_record_tasks'
require 'rock_pape_scis'
require 'digest/sha2'  
require_relative '../lib/rps.rb' # the path to your application file

ActiveRecord::Base.establish_connection(
  :adapter => 'postgresql',
  :database => 'rps'
)