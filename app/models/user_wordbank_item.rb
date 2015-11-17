class UserWordbankItem < ActiveRecord::Base
  belongs_to :user

  delegate :nombre_completo, to: :user, prefix: true

  validates :user_id, presence: true
end
