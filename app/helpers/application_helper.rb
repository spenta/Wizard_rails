module ApplicationHelper
  
  #thresholds for colors display, in proportion on value corresponding to a "right" value
  COLOR_THRESHOLDS_RELATIVE = [0, 0.5, 0.7, 0.8, 0.9, 1.1, 1.3, 1.6, 2]
  COLOR_THRESHOLDS_ABSOLUTE = [-6, -4, -2, -1, 0, 1, 2, 4, 7]

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
    text.gsub(/\[\[[a-zA-Z0-9_]+\|[a-z-A-Z0-9 ,]+\]\]/) do |s|
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
  
  def get_best_pc_for_profile profile
    profile_infos = Rails.cache.read("#{profile}_profile")
    star_products = profile_infos[:star_products]
    #products are sorted by ascending q
    star_products.last
  end
  
  # returns the color code corresponding to the ratio between actual value and target value
  def get_color_number_relative value
    color_number = 0
    color_number += 1 while (value > (COLOR_THRESHOLDS_RELATIVE[color_number]||0) and color_number < COLOR_THRESHOLDS_RELATIVE.size)
    color_number
  end

  # returns the color code corresponding to the difference between actual value and target value
  def get_color_number_absolute value
    color_number = 0
    color_number += 1 while (value >= (COLOR_THRESHOLDS_ABSOLUTE[color_number]||0) and color_number < COLOR_THRESHOLDS_ABSOLUTE.size)
    color_number
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
  
  #ex: [[link_to_article|12,,,super article]]
  def widget_link_to_article arg
    article_id = arg.split(",,,").first
    content = arg.split(",,,").last
    link_to content, article_path(article_id)
    end

end

