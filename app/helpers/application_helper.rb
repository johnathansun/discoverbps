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

	def formatted_time(time)
		time.strftime('%m/%d/%Y - %I:%M %P') if time.present?
	end

	def formatted_date(date)
		date.strftime('%m/%d/%Y') if date.present?
	end

	def formatted_date_name(date)
		"#{date.strftime('%B')} #{(date.strftime('%d')).to_i.ordinalize}" if date.present?
	end

	def registration_date_helper(registration_date, format=nil)
		if rd = registration_date
			if rd.end_date.present?
				if rd.start_date.month != rd.end_date.month
					if format == "month_range"
						"#{rd.start_date.strftime('%b')} - #{rd.end_date.strftime('%b')}"
					elsif format == "start_date_short"
						"#{rd.start_date.strftime('%b')} #{rd.start_date.strftime('%d')}"		
					elsif format == "start_date"
						"#{rd.start_date.strftime('%B')} #{rd.start_date.strftime('%d')}"		
					else
						"#{rd.start_date.strftime('%b %e')} - #{rd.end_date.strftime('%b %e')}"
					end
				elsif format == "start_date_short"
					"#{rd.start_date.strftime('%b')} #{rd.start_date.strftime('%d')}"					
				else	
					"#{rd.start_date.strftime('%b %e')}-#{rd.end_date.strftime('%e')}"
				end
			else
				if format == "full_month"
					"#{rd.start_date.strftime('%B')} #{rd.start_date.strftime('%e')}"
				elsif format == "full_month_date"
					"#{rd.start_date.strftime('%b %e')} - #{rd.end_date.strftime('%b %e')}"
				elsif format == "start_date_short"
					"#{rd.start_date.strftime('%b')} #{rd.start_date.strftime('%d')}"	
				elsif format == "start_date"
					"#{rd.start_date.strftime('%B')} #{rd.start_date.strftime('%d')}"		
				else
					"#{rd.start_date.strftime('%b')} #{rd.start_date.strftime('%e')}"
				end
			end
		end
	end

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

	def transportation_eligibility_icon_helper(student_school, font_size)
		font_size ||= "18px"
		if ['WY', 'K'].include?(student_school.transportation_eligibility)
			raw("<span aria-hidden='true' class='icon-DBPS-Dev-Assets-SRG-14 transportation_icon' style='font-size: #{font_size}; color: #565656;'></span>")
		elsif ['SY', 'C'].include?(student_school.transportation_eligibility)
			raw("<span aria-hidden='true' class='icon-DBPS-Dev-Assets-SRG-15 transportation_icon' style='font-size: #{font_size}; color: #565656;'></span>")
		elsif ['T', 'O'].include?(student_school.transportation_eligibility)
			raw("<span aria-hidden='true' class='icon-DBPS-Dev-Assets-SRG-16 transportation_icon' style='font-size: #{font_size}; color: #565656;'></span>")
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
