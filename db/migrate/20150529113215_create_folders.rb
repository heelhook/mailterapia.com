class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.references :user, index: true
      t.string :name
      t.string :slug, index: true

      t.timestamps null: false
    end
    add_foreign_key :folders, :users

    add_column :messages, :folder_id, :integer, index: true
  end
end
