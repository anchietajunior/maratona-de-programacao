class CreateTestcases < ActiveRecord::Migration[8.1]
  def change
    create_table :testcases do |t|
      t.references :problem, null: false, foreign_key: true
      # Binárias: o collation do MySQL não opina sobre igualdade de texto (ADR-0003).
      t.binary :input, null: false
      t.binary :expected_output, null: false

      t.timestamps
    end
  end
end
