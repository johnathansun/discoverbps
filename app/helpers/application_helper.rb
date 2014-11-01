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

	def last_school_year
		if Date.today.month >= 11
			"#{Date.today.years_ago(1).year}"
		else
			"#{Date.today.year}"
		end
	end

	def last_school_year_range
		if Date.today.month >= 11
			start_year = Date.today.years_ago(1).year
			end_year = Date.today.year
			"#{start_year}-#{end_year}"
		else
			start_year = Date.today.year
			end_year = Date.today.years_since(1).year
			"#{start_year}-#{end_year}"
		end
	end

	def timeline_last_year
		if Date.today.month > 9
			Date.today.year
		else
			Date.today.years_ago(1).year
		end
	end

	def timeline_next_year
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

	def progress_bar_class_helper(student_step, page_step, bar_step)
		if bar_step == 1
			if page_step == 1
				'current'
			elsif student_step >= 1
				'complete'
			end
		elsif bar_step == 2
			if page_step == 2
				'current'
			elsif student_step >= 2
				'complete'
			end
		elsif bar_step == 3
			if page_step == 3
				'current'
			elsif student_step >= 3
				'complete'
			end
		elsif bar_step == 4
			if page_step == 4
				'current'
			elsif student_step >= 4
				'complete'
			end
		end
	end
end
