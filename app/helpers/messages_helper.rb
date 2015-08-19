module MessagesHelper
  def back_path(opts={})
    if @folder
      folder_messages_path(@folder, opts)
    else
      messages_path(opts)
    end
  end
end
