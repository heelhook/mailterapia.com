class MessagesController < ApplicationController
  before_filter :load_resources
  before_action :authenticate_user!
  respond_to :html

  def index
    if ! @folder
      @inbox = current_user.unread_messages | current_user.read_messages
      @inbox = @inbox.reject { |message| ! message.visible_to_user } if ! current_user.admin?
      @inbox = @inbox.reject { |message| message.folder_id }
    else
      @inbox = @folder.messages
    end

    @sent =  current_user.my_messages - current_user.draft_messages
    @sent = @sent.reject { |message| ! message.visible_to_user } if ! current_user.admin?
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
    @message.update_attributes(created_at: Time.now) if params[:message][:body]|| params[:message][:status]
    @message.send_notification if params[:message][:status] && !@message.draft?

    @message = MessageDecorator.new(@message)

    if !request.xhr?
      respond_with @message, location: -> { messages_path }
    else
      head :ok
    end
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

  def destroy
    if @message.draft?
      @message.destroy
    else
      @message.update_attributes(visible_to_user: false)
    end

    respond_with @message, location: -> { messages_path }
  end

  private

  def message_params
    params.require(:message).permit(
      :to_id,
      :subject,
      :body,
      :in_reply_to,
      :status,
      :folder_id,
    )
  end

  def load_resources
    @message = current_user.messages.find(params[:id]) if params[:id]
    @folder = current_user.folders.find(params[:folder_id]) if params[:folder_id]
  end
end
