class CreateAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :answers do |t|
      t.references :clarification, null: false, foreign_key: true, index: { unique: true }
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.boolean :collective, null: false, default: false

      t.timestamps
    end
  end
end
