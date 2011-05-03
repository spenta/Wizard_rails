module ApplicationHelper

  # translate to HTML safe
  def t_safe str
    t((str.to_s.to_sym), :default => "").html_safe 
  end
end
