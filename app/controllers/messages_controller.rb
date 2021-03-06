class MessagesController < ApplicationController
  before_filter :load_resources
  before_action :authenticate_user!
  respond_to :html, :js

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

    if params[:tagged]
      @inbox = @inbox.select {|message| message.all_tags_list.include? params[:tagged] }
      @sent = @sent.select {|message| message.all_tags_list.include? params[:tagged] }
      @drafts = @drafts.select {|message| message.all_tags_list.include? params[:tagged] }
    end
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
    @message.status ||= 'unread'
    @message.body = params[:body] if message_params[:body].empty?
    @message.save
    @message = MessageDecorator.new(@message)

    render json: {
      id: @message.id,
      action: url_for(@message),
    }
  end

  def edit
    @message = MessageDecorator.new(@message)
    render action: :new
  end

  def update
    @message.update_attributes(message_params)
    @message.update_attributes(created_at: Time.now) if params[:message][:body]|| params[:message][:status]
    @message.update_attributes(to_id: Message.default_recipient.id) unless current_user.admin?
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

    @reply = Message.where(in_reply_to: @message, from: current_user, status: Message.statuses['draft']).first_or_initialize

    if @reply.new_record?
      @reply.to = @message.from
      @reply.subject = @message.subject
      @reply.body = "<p></p><hr /><p>#{@message.from.nombre} escribió el #{l @message.created_at, format: :short}:</p><blockquote>#{@message.body}</blockquote>"
      @reply.tag_list = @message.tag_list
    end

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
      :in_reply_to_id,
      :status,
      :folder_id,
      :tag_list,
    )
  end

  def load_resources
    if params[:id]
      @message = current_user.messages.find(params[:id]) rescue nil
      @message ||= current_user.my_messages.find(params[:id]) rescue nil
    end

    @folder = current_user.folders.find(params[:folder_id]) if params[:folder_id]
  end
end
