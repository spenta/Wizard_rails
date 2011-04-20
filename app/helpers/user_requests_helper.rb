module UserRequestsHelper
  def sortable column, title = nil
    title ||= column.titleize
    direction = column == params[:sort] && params[:direction] == "desc" ? "asc" :"desc"
    link_to title, :sort => column, :direction => direction, :start_index => params[:start_index], :num_result => params[:num_result]
  end
end

