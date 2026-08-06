class CreateDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :deliveries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :problem, null: false, foreign_key: true
      t.references :staff, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :deliveries, %i[ user_id problem_id ], unique: true
  end
end
