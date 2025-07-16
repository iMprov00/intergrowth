class CreateMeasurements < ActiveRecord::Migration[8.0]
  def change
        create_table :measurements do |t|
      t.float :gestational_age
      t.string :measurement_type
      t.float :value
      t.string :gender
      t.float :percentile
      t.timestamps
    end
  end
end
