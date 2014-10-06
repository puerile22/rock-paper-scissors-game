class AddColumnPasswordHash < ActiveRecord::Migration
  def change
    add_column :players, :password_hash, :string
  end
end
