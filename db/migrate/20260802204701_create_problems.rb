class CreateProblems < ActiveRecord::Migration[8.1]
  def change
    create_table :problems do |t|
      t.references :contest, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :title, null: false
      t.string :difficulty, null: false
      t.text :statement, null: false
      t.text :reference_solution, null: false

      t.timestamps
    end
    add_index :problems, [ :contest_id, :position ], unique: true
  end
end
