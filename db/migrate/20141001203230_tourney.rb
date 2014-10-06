class Tourney < ActiveRecord::Migration
  def change
    create_table :tourneys do |t|
      t.belongs_to :player
      t.string :move
      t.string :status
      t.belongs_to :tour
    end
  end
end
