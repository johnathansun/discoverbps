module ApplicationHelper

	def timeline_percent(today)
		if today >= Date.new(today.year, 10, 01)
			"#{ ((((today - today.beginning_of_year) - 272) / 365.0).to_f * 100).round }%"
		else
			"#{ (((today - today.beginning_of_year) / 365.0).to_f * 100).round }%"
		end
	end
end
