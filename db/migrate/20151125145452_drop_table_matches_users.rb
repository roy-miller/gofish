class DropTableMatchesUsers < ActiveRecord::Migration
  def change
    drop_table :matches_users
  end
end
