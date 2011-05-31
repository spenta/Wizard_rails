xml.user_requests do
  UserRequest.all.each do |ur|
    xml.user_request(:id => ur.id) do
      xml.is_complete(ur.is_complete)
      xml.user_request_creation_date(ur.created_at)
      xml.user_request_update_date(ur.updated_at)
      ur.usage_choices.each do |uc|
        xml.usage_choice(:id => uc.id) do 
          xml.usage_id(uc.usage_id)
          xml.is_selected(uc.is_selected)
          xml.weight_for_user(uc.weight_for_user)
        end
      end
    end
  end
end
