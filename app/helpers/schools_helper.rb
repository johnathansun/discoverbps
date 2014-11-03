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

	def student_support_list_helper(hash)
		list = ''
		list << 'Full-Time Nurse, '				if hash.try(:[], :HasFullTimeNurse) == 'True'
		list << 'Part-Time Nurse, '				if hash.try(:[], :HasPartTimeNurse) == 'True'
		list << 'Online Health Center, ' 	if hash.try(:[], :HasOnlineHealthCntr) == 'True'
		list << 'Family Coordinator, '		if hash.try(:[], :HasFamilyCoord) == 'True'
		list << 'Guidance Counselor, '		if hash.try(:[], :HasGuidanceCoord) == 'True'
		list << 'Social Worker'					if hash.try(:[], :HasSocialWorker) == 'True'
		list
	end

	def preview_dates_list_helper(hash)
		list = ''
		list << "Preview date 1: #{hash.try(:[], :PreviewDate1)}, " 	if hash.try(:[], :PreviewDate1).present?
		list << "Preview date 2: #{hash.try(:[], :PreviewDate2)}, " 	if hash.try(:[], :PreviewDate2).present?
		list << "Preview date 3: #{hash.try(:[], :PreviewDate3)}, " 	if hash.try(:[], :PreviewDate3).present?
		list << "Preview date 4: #{hash.try(:[], :PreviewDate4)}, " 	if hash.try(:[], :PreviewDate4).present?
		list << "Preview date 5: #{hash.try(:[], :PreviewDate5)}, " 	if hash.try(:[], :PreviewDate5).present?
		list << "Preview date 6: #{hash.try(:[], :PreviewDate6)}" 	if hash.try(:[], :PreviewDate6).present?
		list
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

	def special_application_helper(string)
		if string.blank? || string == 'False'
			'No'
		elsif string == 'True'
			'Yes'
		end
	end

	def awc_helper(string)
		if string.blank? || string == 'No'
			'No'
		elsif string == 'Yes'
			'Yes'
		end
	end

	def spacer_helper(string)
		raw string.try(:strip).try(:gsub, /\s/, '&nbsp;')
	end

end
