class AddMissingFieldsToNewborns < ActiveRecord::Migration[8.0]
  def change
    change_table :newborns do |t|
      t.date :admission_date
      t.date :discharge_date
      t.integer :apgar_1
      t.integer :apgar_5
      t.string :hepatitis_b
      t.string :bcg
      t.string :icd_code
      t.string :hiv
      t.string :fetopathy
      t.string :feeding
      t.string :comorbidities
    end
  end
end
