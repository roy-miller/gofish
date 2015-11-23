class User
  @@users = []
  attr_accessor :id, :name, :match

  def initialize(id: nil, name: nil)
    id.nil? ? @id = object_id : @id = id
    @name = name
    @matches = []
    @@users << self
  end

  def add_match(match)
    @matches << match
  end

  def self.users
    @@users
  end

  def self.reset_users
    @@users = []
  end

  def self.find(id)
    @@users.select { |user| user.id == id }.first
  end
end
