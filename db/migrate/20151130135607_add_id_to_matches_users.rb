class AddIdToMatchesUsers < ActiveRecord::Migration
  def change
    add_column :matches_users, :id, :primary_key
  end
end
