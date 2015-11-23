class User < ActiveRecord::Base
  #attr_accessor :name, :first_name, :last_name, :match
  attr_accessor :matches

  def add_match(match)
    @matches ||= []
    @matches << match
  end
end
