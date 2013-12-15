module ApplicationHelper

	##### Devise mappings, from http://natashatherobot.com/devise-rails-sign-in/
	
	def resource_name
    :user
  end
 
  def resource
    @resource ||= User.new
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

	#####

	def timeline_percent(today)
		if today >= Date.new(today.year, 10, 01)
			"#{ ((((today - today.beginning_of_year) - 272) / 365.0).to_f * 100).round }%"
		else
			"#{ (((today - today.beginning_of_year) / 365.0).to_f * 100).round }%"
		end
	end
end
