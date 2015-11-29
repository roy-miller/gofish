class AddObserversToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :observers, :text
  end
end
