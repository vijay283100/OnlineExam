module ReportsHelper
  
  def descriptive_help(text)
    #include ActionView::Helpers::SanitizeHelper  
    #strip_tags(text)#.to_s.gsub(/(<[^>]+>|&nbsp;|\r|\n|&prod;|<sup>)/,"")
    @a = content_tag :span, "#{text}".html_safe
    return @a
  end
end
