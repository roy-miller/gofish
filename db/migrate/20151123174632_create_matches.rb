class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.string :game
    end
  end
end
