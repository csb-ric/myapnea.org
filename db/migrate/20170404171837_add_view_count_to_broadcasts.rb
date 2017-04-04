class AddViewCountToBroadcasts < ActiveRecord::Migration[5.0]
  def change
    add_column :broadcasts, :view_count, :integer, null: false, default: 0
    add_index :broadcasts, :view_count
  end
end
