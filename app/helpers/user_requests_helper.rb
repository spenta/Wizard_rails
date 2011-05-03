module UserRequestsHelper
  include WizardUtilities

  def sortable column, title = nil
    title ||= column.titleize
    direction = column == params[:sort] && params[:direction] == "desc" ? "asc" :"desc"
    link_to title, :sort => column, :direction => direction, :start_index => 0, :num_result => params[:num_result]
  end

  def get_important_specs_id_from gammas
    gamma_array = gammas.to_a
    #sort by descending value
    gamma_array.sort! {|s2, s1| s1[1] <=> s2[1]}
    #only keeps positive gammas
    gamma_array = gamma_array.select {|s| s[1]>0}
    #array or spec_id by descending importance
    result = gamma_array.collect{|s| s[0]}.first(5)
    #complete with default important specs. In order
    # Screen size (speccification_id 5)
    # CPU (speccification_id 1)
    # Weight (speccification_id 9)
    # RAM (speccification_id 2)
    # HDD (speccification_id 4)
    default_specs = [5, 1, 9, 2, 4]
    default_specs.reverse!
    complete result, :with => default_specs, :until_size_is => 5, :allowing_duplicate => false
    result
  end

  def get_cents_from price
    result = Integer(price.modulo(1).round(2)*100.floor).to_s
    result += "0"
    result[0,2]
  end

  def get_percentage_from score, score_recommended
    ratio = score/score_recommended
    result = (ratio*100).round
  end

  # A product is said to have a low performance (L) if score < 90
  # A product is said to have a medium performance (M) if 90 <= score < 110
  # A product is said to have a high performance (H) if 110 < score
  def category_of product
    if product.spenta_score < 90
      "L"
    elsif product.spenta_score > 110
      "H"
    else
      "M"
    end
  end

  def spec_value_with_unit product, spec_id
    product.specification_values[spec_id][:name]+" "+ t_safe("spec_metrics_#{spec_id}")
  end
end
