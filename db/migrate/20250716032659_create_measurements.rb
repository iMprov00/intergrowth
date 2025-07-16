class CreateMeasurements < ActiveRecord::Migration[6.1]
  def change
    create_table :measurements do |t|
      t.integer :gestational_age, null: false  # в днях
      t.string :gender, null: false            # M/F
      t.float :height, null: false             # мм
      t.float :weight, null: false             # граммы
      t.float :head_circumference, null: false # мм
      t.float :height_percentile
      t.float :weight_percentile
      t.float :hc_percentile
      
      t.timestamps
    end
  end
end