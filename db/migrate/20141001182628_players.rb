class Players < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.integer :wins
      t.integer :losses
    end
  end
end
