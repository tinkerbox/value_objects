$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'value_objects'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
