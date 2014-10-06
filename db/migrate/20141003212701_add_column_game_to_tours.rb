class AddColumnGameToTours < ActiveRecord::Migration
  def change
    add_column :tours, :game, :integer
  end
end
