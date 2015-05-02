class CreateDatabase < ActiveRecord::Migration
  def change
    create_table :metermaid_samples do |t|
      t.integer :time_period_duration
      t.integer :time_period_start
      t.integer :value
      t.integer :reading_type_currency
      t.integer :reading_type_power_of_ten_multiplier
      t.integer :reading_type_uom
      t.string  :address, length: 512
      t.integer :usage_point_service_category_kind
      t.string  :filename, length: 512
      t.string  :sample_hash, length: 512
    end
  end
end
