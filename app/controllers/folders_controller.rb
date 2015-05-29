class FoldersController < ApplicationController
  def create
    Folder.create(folder_params)
    redirect_to messages_path
  end

  private

  def folder_params
    params.require(:folder).permit(
      :name,
    ).merge(
      user: current_user,
    )
  end
end
