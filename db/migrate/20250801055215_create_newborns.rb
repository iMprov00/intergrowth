class CreateNewborns < ActiveRecord::Migration[8.0]
  def change
    create_table :newborns do |t|
      t.string :last_name
      t.string :first_name
      t.string :patronymic
      t.string :gender, limit: 1 # 'M' или 'F'
      t.float :gestational_age # Срок гестации в неделях
      t.string :delivery_method # 'КС' или 'Сам.'
      t.date :birth_date
      t.date :admission_date
      t.date :discharge_date
      t.string :outcome # Исход
      t.float :birth_weight
      t.float :discharge_weight
      t.float :birth_height
      t.integer :apgar_1 # Оценка по Апгар на 1-й минуте
      t.integer :apgar_5 # Оценка по Апгар на 5-й минуте
      t.string :hepatitis_b # 'Да' или 'Нет'
      t.string :bcg # 'Да' или 'Нет'
      t.string :icd_code # Код МКБ
      t.string :hiv # 'Да' или 'Нет'
      t.string :fetopathy # Текст
      t.string :feeding # 'Грудное', 'Смешанное', 'Искусственное'
      t.string :comorbidities # Сопутствующее (текст)

      t.timestamps
    end
  end
end
