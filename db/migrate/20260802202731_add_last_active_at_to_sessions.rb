class AddLastActiveAtToSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :sessions, :last_active_at, :datetime, null: false, default: -> { "CURRENT_TIMESTAMP(6)" }
  end
end
