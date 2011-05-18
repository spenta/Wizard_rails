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
      p_infos[:specification_values][spec_id][:sv_name]+" "+ t_safe("spec_metrics_#{spec_id}")
    rescue
      t :not_communicated
    end
  end

end
