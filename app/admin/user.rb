ActiveAdmin.register User do
  permit_params :name, :email, :slug, :password, :password_confirmation, :active_subscription, :active_service

  index do
    selectable_column
    column :name
    column :email
    column :service_email
    column :created_at
    column :active_subscription
    column :active_service
    column :stripe_token
    column :wordbank_balance
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :name
      f.input :email
      f.input :active_subscription
      f.input :active_service
      f.input :password
      f.input :password_confirmation
      f.input :slug
    end
    f.actions
  end

end