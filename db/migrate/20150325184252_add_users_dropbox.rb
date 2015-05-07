class AddUsersDropbox < ActiveRecord::Migration
  def change
    add_column :users, :dropbox_link, :string
  end
end
