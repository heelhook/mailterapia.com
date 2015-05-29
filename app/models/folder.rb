class Folder < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [ :slugged, :finders, :scoped ], scope: :user
  belongs_to :user
  has_many :messages

  validates :name, uniqueness: { scope: :user_id }
end
