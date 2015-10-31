class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :generate_slug, use: [ :slugged, :finders ]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  belongs_to :consultation_type
  has_many :wordbank_items, class_name: 'UserWordbankItem'
  has_many :messages, foreign_key: :to_id
  has_many :my_messages, class_name: 'Message', foreign_key: :from_id
  has_many :unread_messages, -> { unread }, class_name: 'Message', foreign_key: :to_id
  has_many :read_messages, -> { read }, class_name: 'Message', foreign_key: :to_id
  has_many :draft_messages, -> { draft }, class_name: 'Message', foreign_key: :from_id
  has_many :folders

  validates :nombre, :apellido, :email, presence: true
  validates :email, uniqueness: true
  validates :condiciones_de_servicio, acceptance: true, on: :create, allow_nil: false

  enum role: [:user, :admin]
  after_initialize :set_default_role, :if => :new_record?

  after_create :send_email, :subscribe_to_newsletter

  attr_accessor :condiciones_de_servicio, :newsletter

  after_initialize :initialize_with_defaults, if: :new_record?

  acts_as_tagger

  def initialize_with_defaults
    @newsletter ||= true
  end

  def all_messages
    messages | my_messages
  end

  def send_email
    password = Devise.friendly_token.first(8)
    self.update_attributes(password: password)

    TransactionMailer.welcome(self, password).deliver
    TransactionMailer.notification_new_user(self).deliver
  end

  def subscribe_to_newsletter
    puts "Newsletter"
    p @newsletter
    if @newsletter != "0"
      puts "going to register user"
      begin
        response = Rails.configuration.mailchimp.lists.subscribe({
          id: MAILCHIMP_LIST_ID,
          email: { email: email },
          merge_vars: {
            FNAME: nombre,
            LNAME: apellido,
          },
          double_optin: false,
        })
        p response
      rescue Gibbon::MailChimpError => e
      end
    else
      puts "not registering the new user"
    end
  end

  def set_default_role
    self.role ||= :user
  rescue
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  def nombre_completo
    "#{nombre} #{apellido}"
  end

  def generate_slug
    [ nombre_completo[0..15] ]
  end

  def stripe_customer
    return nil unless stripe_token

    customer = Stripe::Customer.retrieve(stripe_token) rescue nil
    return nil if !customer || customer.try(:deleted)
    customer
  end

  def chargable_stripe_customer?
    customer = stripe_customer
    customer && customer.sources.all(object: 'card').count > 0
  end

  def service
    case
    when active_service == 'consulta-expres' then 'consulta-expres'
    when active_subscription == 'suscripcion-ilimitada' then 'suscripcion-ilimitada'
    when wordbank_balance > 0 then 'wordbank'
    end
  end

  def wordbank_balance
    wordbank_items.inject(0) { |mem, var| mem += var.word_count }
  end

  def active_subscription?
    active_subscription == 'suscripcion-ilimitada'
  end

  def active_service?
    active_service == 'consulta-expres'
  end

  def access_to_service?
    wordbank_balance > 0 ||
    active_subscription? ||
    active_service? ||
    admin?
  end

  def access_to_communication?
    access_to_service? || stripe_token || admin?
  end

  def service_email
    "marina@mailterapia.com"
  end
end
