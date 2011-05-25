module ApplicationHelper

  #def check_cache_state
    #build_cache unless Rails.cache.read('cache_state') == 'complete'
  #end

  # translate to HTML safe
  def t_safe str
    t((str.to_s.to_sym), :default => "").html_safe
  end

  def build_cache
    Rails.cache.write('cache_state', 'busy')
    Product.all_cached.each do |p|
      p.infos
    end
    Requirement.usages_requirements
    Requirement.mobilities_requirements
    Specification.all_cached
    Rails.cache.write('cache_state', 'complete')
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

