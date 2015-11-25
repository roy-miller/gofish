class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |table|
      table.text :game_serial
      table.string :status
      table.text :messages, array: true, default: []
      table.integer :winner_id
      table.timestamps null: false
    end

    create_table :matches_users, id: false do |table|
      table.belongs_to :match, index: true
      table.belongs_to :user, index: true
    end
  end
end
