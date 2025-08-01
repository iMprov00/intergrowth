class AddOutcomeToNewborns < ActiveRecord::Migration[8.0]
  def change
    add_column :newborns, :outcome, :string
  end
end
