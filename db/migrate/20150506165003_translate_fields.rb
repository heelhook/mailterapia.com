class TranslateFields < ActiveRecord::Migration
  def change
    rename_column :users, :first_name, :nombre
    rename_column :users, :last_name, :apellido
  end
end
