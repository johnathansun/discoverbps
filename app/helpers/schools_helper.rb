module SchoolsHelper
	def facilities_list_helper(hash)
		if hash.present?
			list = ''
			list << 'Art Room, ' 						if hash[:hasartroom] == 'True'
			list << 'Athletic Field, ' 			if hash[:hasathleticfield] == 'True'
			list << 'Auditorium, ' 					if hash[:hasauditorium] == 'True'
			list << 'Cafeteria, ' 					if hash[:hascafeteria] == 'True'
			list << 'Computer Lab, ' 				if hash[:hascomputerlab] == 'True'
			list << 'Gymnasium, ' 					if hash[:hasgymnasium] == 'True'
			list << 'Library, ' 						if hash[:haslibrary] == 'True'
			list << 'Music Room, ' 					if hash[:hasmusicroom] == 'True'
			list << 'Outdoor Classrooms, ' 	if hash[:hasoutdoorclassroom] == 'True'
			list << 'Playground, ' 					if hash[:hasplayground] == 'True'
			list << 'Pool, ' 								if hash[:haspool] == 'True'
			list << 'Science Lab'	 					if hash[:hassciencelab] == 'True'
			return list.strip.gsub(/,$/, '')
		else
			return nil
		end
	end

	def sports_list_helper(hash)
		if hash.present?
			list = ''
			list << 'Baseball, ' 						if hash[:Baseball] == true
			list << 'Basketball, ' 					if (hash[:boyBasketball] == true || hash[:girlBasketball] == true)
			list << 'Cheerleading, ' 				if hash[:Cheer] == true
			list << 'Cross Country, ' 			if (hash[:boyCrossCountry] == true || hash[:girlCrossCountry] == true)
			list << 'Double Dutch, ' 				if (hash[:boyDoubleDutch] == true || hash[:girlDoubleDutch] == true)
			list << 'Football, ' 						if hash[:Football] == true
			list << 'Golf, '								if hash[:Golf] == true
			list << 'Hockey, ' 							if hash[:Hockey] == true
			list << 'Indoor Track, ' 				if (hash[:boyIndoorTrack] == true || hash[:girlIndoorTrack] == true)
			list << 'Soccer, ' 							if (hash[:boySoccer] == true || hash[:girlSoccer] == true)
			list << 'Softball, ' 						if hash[:Softball] == true
			list << 'Swimming, ' 						if (hash[:boySwim] == true || hash[:girlSwim] == true)
			list << 'Tennis, ' 							if (hash[:boyTennis] == true || hash[:girlTennis] == true)
			list << 'Track, ' 							if (hash[:boyOutdoorTrack] == true || hash[:girlOutdoorTrack] == true)
			list << 'Volleyball, ' 					if (hash[:boyVolleyball] == true || hash[:girlVolleyball] == true)
			list << 'Wrestling' 						if hash[:Wrestling] == true
			return list.strip.gsub(/,$/, '')
		else
			return nil
		end
	end

	def eligibility_helper(tier)
		tier.try(:gsub, /:/, ', ')
	end

	def school_tier_helper(tier)
		if tier.present?
			if tier == 'NR'
				tier_name = 'Not Ranked'
			elsif tier == 'N/A'
				tier_name = 'Not Applicable'
			else
				tier_name = "Tier #{tier}"
			end
			return tier_name
		else
			return ''
		end
	end

	def grade_levels_helper(array)
		if array.present?
			if array.length == 0
				"N/A"
			elsif array.length == 1
				array[0]
			else
				"#{array[0]} - #{array[-1]}"
			end
		else
			return nil
		end
	end

	def partners_list_helper(array)
		if array.present?
			list = ''
			array.each do |partner|
				list << "#{partner[:description]}, "
			end
			return list.gsub(/,\s?$/, '')
		else
			return nil
		end
	end

	def school_hours_start_time_helper(hours)
		if hours.present?
			hour 			= hours.match(/^\d*/).to_s.to_i
			minutes 	= hours.match(/^\d*:\d*/).to_s.gsub(/^\d*:/,'').to_s.to_i
			decimal 	= hour + (minutes / 60.0)
			range_percent = (decimal - 7) / 17
			(range_percent * 100).to_i
		else
			return ''
		end
	end

	def school_hours_end_time_helper(hours)
		if hours.present?
			hour 		= hours.gsub(/am/,'').gsub(/pm/,'').match(/-\s?\d*:/).to_s.gsub(/-\s?/,'').gsub(/:/,'').to_s.to_i
			minutes = hours.gsub(/am/,'').gsub(/pm/,'').match(/-\s?\d*:\d*/).to_s.gsub(/-\s?\d*:/,'').to_s.to_i
			hour += 12 if (hour > 0 && hour < 8) # add 12 if it's pm
			decimal = hour + (minutes / 60.0)
			range_percent = (17 - decimal) / 17
			(range_percent * 100).to_i
		end
	end

	def spacer_helper(string)
		raw string.try(:strip).try(:gsub, /\s/, '&nbsp;')
	end

	################ helper methods fo generating category data tags

	def preference_category_tags_helper(category, school, student_school)
		if category.name == 'Grades Offered'
			tags = grade_levels_tags_helper(school.api_basic_info.try(:[], :GradesOffered), student_school)

		elsif category.name == 'Facility Features'
			tags = facilities_tags_helper(school.api_facilities)
		
		elsif category.name == 'Sports'
			tags = sports_tags_helper(school.api_sports)
		
		elsif category.name == 'Health & Wellness'
			tags = health_tags_helper(school.api_basic_info)
		
		elsif category.name == 'Enrollment'
			tags = enrollment_tags_helper(school.api_basic_info)

		elsif category.name == 'Uniform Policy'
			tags = uniform_policy_tags_helper(school.api_description)
		end
		
		return tags
	end

	def facilities_tags_helper(hash)
		if hash.present?
			list = []
			list << 'Art Room' 						if hash[:hasartroom] == 'True'
			list << 'Athletic Field' 			if hash[:hasathleticfield] == 'True'
			list << 'Auditorium' 					if hash[:hasauditorium] == 'True'
			list << 'Cafeteria' 					if hash[:hascafeteria] == 'True'
			list << 'Computer Lab' 				if hash[:hascomputerlab] == 'True'
			list << 'Gymnasium' 					if hash[:hasgymnasium] == 'True'
			# list << 'Handicap Accessible'
			list << 'Library' 						if hash[:haslibrary] == 'True'
			list << 'Music Room' 					if hash[:hasmusicroom] == 'True'
			list << 'Outdoor Classrooms' 	if hash[:hasoutdoorclassroom] == 'True'
			list << 'Playground' 					if hash[:hasplayground] == 'True'
			list << 'Pool' 								if hash[:haspool] == 'True'
			list << 'Science Lab' 				if hash[:hassciencelab] == 'True'
			return list
		else
			return nil
		end
	end

	def sports_tags_helper(hash)
		if hash.present?
			list = []

			list << 'Baseball' 						if hash[:Baseball] == true
			list << 'Basketball' 					if (hash[:boyBasketball] == true || hash[:girlBasketball] == true)
			list << 'Cheerleading' 				if hash[:Cheer] == true
			list << 'Cross Country' 			if (hash[:boyCrossCountry] == true || hash[:girlCrossCountry] == true)
			list << 'Double Dutch' 				if (hash[:boyDoubleDutch] == true || hash[:girlDoubleDutch] == true)
			list << 'Football' 						if hash[:Football] == true
			list << 'Golf' 								if hash[:Golf] == true
			list << 'Hockey' 							if hash[:Hockey] == true
			list << 'Indoor Track' 				if (hash[:boyIndoorTrack] == true || hash[:girlIndoorTrack] == true)
			list << 'Soccer' 							if (hash[:boySoccer] == true || hash[:girlSoccer] == true)
			list << 'Softball' 						if hash[:Softball] == true
			list << 'Swimming' 						if (hash[:boySwim] == true || hash[:girlSwim] == true)
			list << 'Tennis' 							if (hash[:boyTennis] == true || hash[:girlTennis] == true)
			list << 'Track' 							if (hash[:boyOutdoorTrack] == true || hash[:girlOutdoorTrack] == true)
			list << 'Volleyball' 					if (hash[:boyVolleyball] == true || hash[:girlVolleyball] == true)
			list << 'Wrestling' 					if hash[:Wrestling] == true
			return list
		else
			return nil
		end
	end

	def health_tags_helper(hash)
		if hash.present?
			list = []
			if hash[:ishasfulltimenurse] == 'True'
				list << 'Full-Time Nurse' 
			else
				list << 'Part-Time Nurse' 
			end
			return list
		else
			return nil
		end
	end

	def uniform_policy_tags_helper(hash)
		# ["", "No Uniform", "Not Specified", "Voluntary", "Mandatory", "Varies"] 
		if hash.present?
			list = []
			if hash[:uniformpolicy] == 'Mandatory'
				list << 'Mandatory'
			elsif hash[:uniformpolicy] == 'No Uniform'
				list << 'None'
			elsif hash[:uniformpolicy] == 'Not Specified'
				list << 'Varies'
			elsif hash[:uniformpolicy] == 'Varies'
				list << 'Varies'
			elsif hash[:uniformpolicy] == 'Voluntary'
				list << 'None'
			else
				list << 'None'
			end
			return list
		else
			return nil
		end
	end

	def enrollment_tags_helper(hash)
		if hash.present?
			list = []
			list << hash[:SchSize]
			return list
		else
			return nil
		end
	end

	def grade_levels_tags_helper(grades_offered, student_school)
		# '7-12 (Exam)'
		tags = []
		tags << 'Early Learning Center' if (grades_offered == 'K-1 (EEC)')
		tags << 'K-5 (Elementary)' if (grades_offered == 'K-5 (Elementary)')
		tags << 'K-8' if (grades_offered == 'K-8')
		tags << '6-8 (Middle)' if (grades_offered == '6-8 (Middle)')
		tags << '6-12' if (grades_offered == '6-12')
		tags << '7-12 (Exam)' if (grades_offered == '7-12 (Exam)') && student_school.exam_school?
		tags << '9-12 (High)' if (grades_offered == '9-12 (High)')
		return tags
	end

end
