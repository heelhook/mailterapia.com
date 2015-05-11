class MessagesController < ApplicationController
  before_filter :load_resources
  respond_to :html

  def index
    @inbox = current_user.unread_messages | current_user.read_messages
    @sent =  current_user.my_messages - current_user.draft_messages
    @drafts = current_user.draft_messages
  end

  def new
    @in_reply_to = @message
    @message = Message.new
    if @in_reply_to
      @message.in_reply_to = @in_reply_to
      @message.to = @in_reply_to.from
      @message.subject = @in_reply_to.try(:subject)
    else
      @message.to = Message.default_recipient
    end

    @message = MessageDecorator.new(@message)
  end

  def create
    @message = Message.new(message_params)
    @message.from = current_user
    @message.to = Message.default_recipient unless current_user.admin?
    @message.save
    @message = MessageDecorator.new(@message)

    respond_with @message, location: -> { messages_path }
  end

  def edit
    @message = MessageDecorator.new(@message)
    render action: :new
  end

  def update
    @message.update_attributes(message_params)

    unless @message.draft?
      @message.update_attributes(created_at: Time.now)
      @message.send_notification
    end
    @message = MessageDecorator.new(@message)
    respond_with @message, location: -> { messages_path }
  end

  def show
    @message.read! if @message.unread?
    @message = @message.decorate

    @reply = Message.new(
      in_reply_to: @message,
      to: @message.from,
      subject: @message.subject,
      body: @message.body,
    )
    @reply = @reply.decorate
  end

  private

  def message_params
    params.require(:message).permit(
      :to_id,
      :subject,
      :body,
      :in_reply_to,
      :status,
    )
  end

  def load_resources
    @message = Message.find(params[:id]) if params[:id]
  end
end
