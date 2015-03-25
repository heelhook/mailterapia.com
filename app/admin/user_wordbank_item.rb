ActiveAdmin.register UserWordbankItem do
  permit_params :user_id, :word_count, :memo

  index do
    selectable_column
    id_column
    column :user
    column :word_count
    column :memo
    column :created_at
    actions
  end

  filter :user
  filter :word_count
  filter :memo
  filter :created_at

  form do |f|
    f.inputs "Wordbank Item" do
      f.input :user
      f.input :word_count
      f.input :memo
    end
    f.actions
  end

end
