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

	def current_school_year
		if Date.today.month >= 11
			"#{Date.today.years_ago(1).year}"
		else
			"#{Date.today.year}"
		end
	end

	def current_school_year_range
		if Date.today.month >= 11
			start_year = Date.today.year
			end_year = Date.today.years_since(1).year
			"#{start_year}-#{end_year}"
		else
			start_year = Date.today.years_ago(1).year
			end_year = Date.today.year
			"#{start_year}-#{end_year}"
		end
	end

	def last_school_year
		if Date.today.month >= 11
			"#{Date.today.year}"
		else
			"#{Date.today.years_since(1).year}"
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

	def transportation_eligibility_icon_helper(student_school)
		if ['WY', 'K'].include?(student_school.transportation_eligibility)
			raw("<span aria-hidden='true' class='icon-DBPS-Dev-Assets-SRG-14 transportation_icon' style='font-size: 18px; color: #565656;'></span>")
		elsif ['SY', 'C'].include?(student_school.transportation_eligibility)
			raw("<span aria-hidden='true' class='icon-DBPS-Dev-Assets-SRG-15 transportation_icon' style='font-size: 18px; color: #565656;'></span>")
		elsif ['T', 'O'].include?(student_school.transportation_eligibility)
			raw("<span aria-hidden='true' class='icon-DBPS-Dev-Assets-SRG-16 transportation_icon' style='font-size: 18px; color: #565656;'></span>")
		end
	end

	def progress_bar_class_helper(student_step, page_step, bar_step)
		class_style_list = ''

		if student_step.present? && page_step.present? && bar_step.present?
			# if the student's last touched page is the same as the step in question, make the step in progress
			if student_step == bar_step
				class_style_list += 'in_progress '
			# otherwise, if the student's last touched page is greater than the step in question, make the current step as complete
			elsif student_step > bar_step
				class_style_list += 'complete '
			end

			# if the current page is the same as the step in question, mark the step as current
			if page_step == bar_step
				class_style_list += 'current '
			end
		end

		return class_style_list
	end
end
