class CreateClarifications < ActiveRecord::Migration[8.1]
  def change
    create_table :clarifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :problem, null: false, foreign_key: true
      t.text :question, null: false

      t.timestamps
    end
  end
end
