class MessageDecorator < Draper::Decorator
  include ActionView::Helpers::TextHelper
  delegate_all

  def body_paragraphs
    simple_format(object.body).split(/<\/p>/).map do |paragraph|
      paragraph
    end
  end

  def body_for_editor
    object.body || ""
  end
end
