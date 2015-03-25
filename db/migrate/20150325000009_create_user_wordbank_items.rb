class CreateUserWordbankItems < ActiveRecord::Migration
  def change
    create_table :user_wordbank_items do |t|
      t.references :user, index: true
      t.string :memo
      t.integer :word_count

      t.timestamps null: false
    end
    add_foreign_key :user_wordbank_items, :users
  end
end
