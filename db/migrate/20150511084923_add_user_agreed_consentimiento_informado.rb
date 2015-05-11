class AddUserAgreedConsentimientoInformado < ActiveRecord::Migration
  def change
    add_column :users, :agreed_consentimiento_informado, :boolean, default: false
  end
end
