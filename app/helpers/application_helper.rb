module ApplicationHelper

  # translate to HTML safe
  def t_safe str
    t((str.to_s.to_sym), :default => "").html_safe
  end

  def get_cents_from price
    result = Integer(price.modulo(1).round(2)*100.floor).to_s
    result += "0"
    result[0,2]
  end

  def spec_value_with_unit p_infos, spec_id
    begin
      result = p_infos[:specification_values][spec_id][:sv_name]+" "+ t_safe("spec_metrics_#{spec_id}")
      result += " *" unless p_infos[:specification_values][spec_id][:sv_is_exact]
      result
    rescue
      t :not_communicated
    end
  end

  def cat_subtitle
    str = "#{t :cat_subtitle_1 } <strong>#{Product.all_cached.size} #{t :cat_subtitle_2 }</strong> #{t :cat_subtitle_3} <strong>#{Retailer.count} #{t :cat_subtitle_4}</strong> #{t :cat_subtitle_5}"
    str.html_safe
  end

  def render_widgets text
    #text.gsub(/\[\[[a-zA-Z0-9]+\|[a-zA-Z0-9,]+\]\]/){|s| $2}
    text.gsub(/\[\[[a-zA-Z0-9_]+\|[a-z-A-Z0-9]+\]\]/) do |s|
      widget_name = "widget_#{s.split('|').first.split("[[").last}"
      widget_argument = "#{s.split('|').last.split("]]").first}"
      begin
        send(widget_name, widget_argument)
      rescue => error
        raise error
        #raise "no such widget as #{widget_name}"
      end
    end
  end

  private

  #---------------------
  # Widget definition
  #---------------------


  #widget definition go here
  #they must start by "widget_" and must have one and only one argument (a string)
  #example below
  
  #def widget_test argument
    #argument*3
  #end
  
  #Widget are called in the view with the following syntax
  #   render_widgets("blablabla [[user_profile|gamer]] fsdgdgf")
  #The string [[user_profile|gamer]] will then be replace by widget_user_profile("gamer")

end

