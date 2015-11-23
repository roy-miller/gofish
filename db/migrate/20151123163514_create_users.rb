class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.belongs_to :match, index: true
      t.string :name
      t.string :first_name
      t.string :last_name
      t.timestamps null: false
    end
  end
end
