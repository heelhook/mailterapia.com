ActiveAdmin.register ConsultationType do
  permit_params :name, :description

  index do
    selectable_column
    id_column
    column :name
    column :description
    actions
  end

  filter :name
  filter :description

  form do |f|
    f.inputs "Consultation Type Details" do
      f.input :name
      f.input :description
    end
    f.actions
  end

end
