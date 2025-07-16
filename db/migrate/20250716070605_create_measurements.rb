class CreateMeasurements < ActiveRecord::Migration[6.1]
  def change
    create_table :measurements do |t|
      t.integer :gestational_weeks, null: false
      t.integer :gestational_days, null: false
      t.string :gender, null: false
      t.float :height, null: false
      t.float :weight, null: false
      t.float :head_circumference, null: false
      t.float :height_z
      t.float :weight_z
      t.float :hc_z
      t.float :height_percentile
      t.float :weight_percentile
      t.float :hc_percentile
      
      t.timestamps
    end
  end
end