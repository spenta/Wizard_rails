xml.user_requests do
  UserRequest.all.each do |ur|
    xml.user_request(:id => ur.id) do
      xml.is_complete(ur.is_complete)
      xml.request_creation_date(ur.created_at)
      xml.request_update_date(ur.updated_at)
      ur.usage_choices.where(:is_selected => true).each do |uc|
        xml.usage_choice(:id => uc.id) do 
          xml.usage_id(uc.usage_id)
          xml.weight_for_user(uc.weight_for_user)
        end
      end
    end
  end
end
