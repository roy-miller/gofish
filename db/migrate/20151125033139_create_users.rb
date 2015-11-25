class CreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |table|
      table.string :name, index: true
      table.timestamps null: false
    end
  end
end
