class Message < ActiveRecord::Base
  belongs_to :from, class_name: 'User'
  belongs_to :to, class_name: 'User'
  belongs_to :in_reply_to, class_name: 'Message'
  belongs_to :folder

  has_many :replies, class_name: 'Message', foreign_key: :in_reply_to_id

  validates :from_id, :to_id, presence: true

  default_scope { order(created_at: :desc)}
  scope :unread, -> { where(status: Message.statuses['unread']) }
  scope :read, -> { where(status: Message.statuses['read']) }
  scope :draft, -> { where(status: Message.statuses['draft']) }

  enum status: [ :unread, :read, :replied, :draft ]

  after_create :send_notification

  acts_as_taggable

  def self.default_recipient
    User.where(role: User.roles['admin']).first
  end

  def unread!
    super
    send_notification
  end

  def send_notification
    TransactionMailer.new_message_notification(self).deliver unless draft?
  end

  def draft_id
    self.id
  end
end
