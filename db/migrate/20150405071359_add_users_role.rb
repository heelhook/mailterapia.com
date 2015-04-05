class AddUsersRole < ActiveRecord::Migration
  def change
    add_column :users, :role, :integer
  rescue
    puts "Already there"
  end
end
