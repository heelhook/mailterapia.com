ActiveAdmin.register User do
  permit_params :nombre, :apellido, :email, :slug, :password, :password_confirmation, :active_subscription, :active_service, :dropbox_link

  index do
    selectable_column
    column :nombre
    column :email
    column :service_email
    column :created_at
    column :active_subscription
    column :active_service
    column :stripe_token
    column :wordbank_balance
    column :dropbox_link
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :nombre
      f.input :apellido
      f.input :email
      f.input :active_subscription
      f.input :active_service
      f.input :dropbox_link
      f.input :password
      f.input :password_confirmation
      f.input :stripe_token
      f.input :slug
    end
    f.actions
  end

end
