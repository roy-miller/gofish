class User
  attr_accessor :id, :name
  @@users = []

  def initialize(id: nil, name: nil)
    id.nil? ? @id = object_id : @id = id
    @name = name
    @@users << self
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
