class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :from, index: true
      t.references :to, index: true
      t.string :subject
      t.text :body
      t.integer :status

      t.timestamps null: false
    end
    add_foreign_key :messages, :froms
    add_foreign_key :messages, :tos
  end
end
