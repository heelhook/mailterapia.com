class AddUsersActiveService < ActiveRecord::Migration
  def change
    add_column :users, :active_service, :string
  end
end
