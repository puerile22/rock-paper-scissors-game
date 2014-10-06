class AddColumnRoundToTourneys < ActiveRecord::Migration
  def change
    add_column :tourneys, :round, :integer
  end
end
