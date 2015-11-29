require 'sinatra/activerecord'

class User < ActiveRecord::Base
  has_and_belongs_to_many :matches
end
