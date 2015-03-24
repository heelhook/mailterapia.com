class AddUserInformation < ActiveRecord::Migration
  def change
    add_column :users, :consultation_type_id, :integer
    add_column :users, :consultation_description, :string
  end
end
