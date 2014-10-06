class Tours < ActiveRecord::Migration
  def change
    create_table :tours do |t|
      t.string :name
      t.string :winner
      t.string :rule
    end
  end
end
