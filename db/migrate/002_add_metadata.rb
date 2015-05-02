class AddMetadata < ActiveRecord::Migration
  def up
    Metermaid::DB::Sample.delete_all
    add_column :samples, :additional_metadata, :json
  end

  def down
    remove_column :samples, :additional_metadata
  end
end
