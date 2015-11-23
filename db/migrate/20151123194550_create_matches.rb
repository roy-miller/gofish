class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.string :game
      t.string :status
      t.string :messages, array: true, default: []
      t.timestamps null: false
    end
  end
end
