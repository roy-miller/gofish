class RenameMatchesGameSerial < ActiveRecord::Migration
  def change
    rename_column :matches, :game_serial, :game
  end
end
