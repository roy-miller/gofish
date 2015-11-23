require 'sinatra/activerecord'

class User < ActiveRecord::Base
  attr_accessor :matches

  def add_match(match)
    @matches ||= []
    @matches << match
  end
end
