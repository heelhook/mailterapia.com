class UserWordbankItem < ActiveRecord::Base
  belongs_to :user

  delegate :nombre_completo, to: :user, prefix: true
end
