class AddMessageInReplyToId < ActiveRecord::Migration
  def change
    add_column :messages, :in_reply_to_id, :integer, index: true
  end
end
