class AddVisibleToUserFlag < ActiveRecord::Migration
  def change
    add_column :messages, :visible_to_user, :boolean, default: true
  end
end
