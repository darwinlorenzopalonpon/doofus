module ApplicationHelper
  require "redcarpet"

  def markdown(text)
    return "" if text.blank?

    renderer = Redcarpet::Render::HTML.new(hard_wrap: true, filter_html: true)
    options = {
      autolink: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      lax_html_blocks: true,
      strikethrough: true,
      superscript: true,
      tables: true
    }

    markdown = Redcarpet::Markdown.new(renderer, options)
    markdown.render(text).html_safe
  rescue StandardError => e
    Rails.logger.error("Markdown rendering failed: #{e.message}")
    simple_format(text).html_safe
  end
end
