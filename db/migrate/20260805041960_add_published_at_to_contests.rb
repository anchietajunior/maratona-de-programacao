class AddPublishedAtToContests < ActiveRecord::Migration[8.1]
  def change
    add_column :contests, :published_at, :datetime
  end
end
