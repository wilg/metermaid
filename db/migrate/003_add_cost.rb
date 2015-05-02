class AddCost < ActiveRecord::Migration
  def up
    add_column :samples, :cost, :integer
  end

  def down
    remove_column :samples, :cost
  end
end
