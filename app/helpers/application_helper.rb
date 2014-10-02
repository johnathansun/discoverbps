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

	def last_year_helper
		if Date.today.month > 9
			Date.today.year
		else
			Date.today.years_ago(1).year
		end
	end

	def next_year_helper
		if Date.today.month > 9
			Date.today.years_since(1).year
		else
			Date.today.year
		end
	end

	def timeline_percent(today)
		if today >= Date.new(today.year, 10, 01)
			"#{ ((((today - today.beginning_of_year).to_f - 273) / 365) * 100).round }%"
		else
			"#{ ((((today - today.beginning_of_year).to_f + 93) / 365) * 100).round }%"
		end
	end
end
