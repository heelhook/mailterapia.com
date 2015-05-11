ActiveAdmin.register UserWordbankItem do
  permit_params :user_id, :word_count, :memo

  index do
    selectable_column
    column :user_nombre_completo
    column :word_count
    column :memo
    column :created_at
    actions
  end

  filter :user_nombre_completo
  filter :word_count
  filter :memo
  filter :created_at

  form do |f|
    f.inputs "Wordbank Item" do
      f.input :user, as: :select, collection: User.all.map{|a| [a.nombre_completo, a.id]}
      f.input :word_count
      f.input :memo
    end
    f.actions
  end

end
