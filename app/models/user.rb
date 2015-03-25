class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [ :slugged, :finders ]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  belongs_to :consultation_type
  has_many :wordbank_items, class_name: 'UserWordbankItem'

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  enum role: [:user, :admin]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable


  def stripe_customer
    return nil unless stripe_token

    Stripe::Customer.retrieve stripe_token rescue nil
  end

  def chargable_stripe_customer?
    customer = stripe_customer
    customer && customer.sources.all(object: 'card').count > 0
  end

  def wordbank_balance
    wordbank_items.inject(0) { |mem, var| mem += var.word_count }
  end

  def active_subscription?
    active_subscription == 'suscripcion-ilimitada'
  end

  def active_service?
    active_service == 'consulta-360'
  end

  def access_to_service?
    wordbank_balance > 0 ||
    active_subscription? ||
    active_service?
  end

  def service_email
    "marina-#{slug}@consultas.mailterapia.com"
  end
end
