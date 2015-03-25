class AddUserSubs < ActiveRecord::Migration
  def change
    add_column :users, :active_subscription, :string
  end
end
