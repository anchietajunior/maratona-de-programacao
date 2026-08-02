class CreateContests < ActiveRecord::Migration[8.1]
  def change
    create_table :contests do |t|
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
