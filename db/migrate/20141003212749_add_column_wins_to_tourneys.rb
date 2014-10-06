class AddColumnWinsToTourneys < ActiveRecord::Migration
  def change
    add_column :tourneys, :wins, :integer
  end
end
