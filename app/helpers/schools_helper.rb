module SchoolsHelper

	def facilities_list_helper(hash)
		if hash.present?
			array = []
			array << 'Art Room' 							if hash[:hasartroom] == 'True'
			array << 'Athletic Field' 				if hash[:hasathleticfield] == 'True'
			array << 'Auditorium' 						if hash[:hasauditorium] == 'True'
			array << 'Cafeteria' 							if hash[:hascafeteria] == 'True'
			array << 'Computer Lab' 					if hash[:hascomputerlab] == 'True'
			array << 'Gymnasium' 							if hash[:hasgymnasium] == 'True'
			array << 'Library' 								if hash[:haslibrary] == 'True'
			array << 'Music Room' 						if hash[:hasmusicroom] == 'True'
			array << 'Outdoor Classrooms' 		if hash[:hasoutdoorclassroom] == 'True'
			array << 'Playground' 						if hash[:hasplayground] == 'True'
			array << 'Pool' 									if hash[:haspool] == 'True'
			array << 'Science Lab'	 					if hash[:hassciencelab] == 'True'
			return array.compact
		else
			return []
		end
	end

	def sports_list_helper(hash)
		if hash.present?
			array = []
			array << 'Baseball' 						if hash[:Baseball] == true
			array << 'Basketball' 					if (hash[:boyBasketball] == true || hash[:girlBasketball] == true)
			array << 'Cheerleading' 				if hash[:Cheer] == true
			array << 'Cross Country' 				if (hash[:boyCrossCountry] == true || hash[:girlCrossCountry] == true)
			array << 'Double Dutch' 				if (hash[:boyDoubleDutch] == true || hash[:girlDoubleDutch] == true)
			array << 'Football' 						if hash[:Football] == true
			array << 'Golf'									if hash[:Golf] == true
			array << 'Hockey' 							if hash[:Hockey] == true
			array << 'Indoor Track' 				if (hash[:boyIndoorTrack] == true || hash[:girlIndoorTrack] == true)
			array << 'Soccer' 							if (hash[:boySoccer] == true || hash[:girlSoccer] == true)
			array << 'Softball' 						if hash[:Softball] == true
			array << 'Swimming' 						if (hash[:boySwim] == true || hash[:girlSwim] == true)
			array << 'Tennis' 							if (hash[:boyTennis] == true || hash[:girlTennis] == true)
			array << 'Track' 								if (hash[:boyOutdoorTrack] == true || hash[:girlOutdoorTrack] == true)
			array << 'Volleyball' 					if (hash[:boyVolleyball] == true || hash[:girlVolleyball] == true)
			array << 'Wrestling' 						if hash[:Wrestling] == true
			return array.compact
		else
			return []
		end
	end

	def student_support_list_helper(hash)
		if hash.present?
			array = []
			array << 'Full-Time Nurse'				if hash.try(:[], :HasFullTimeNurse) == 'True'
			array << 'Part-Time Nurse'				if hash.try(:[], :HasPartTimeNurse) == 'True'
			array << 'Online Health Center' 	if hash.try(:[], :HasOnlineHealthCntr) == 'True'
			array << 'Family Coordinator'			if hash.try(:[], :HasFamilyCoord) == 'True'
			array << 'Guidance Counselor'			if hash.try(:[], :HasGuidanceCoord) == 'True'
			array << 'Social Worker'					if hash.try(:[], :HasSocialWorker) == 'True'
			return array.compact
		else
			return []
		end
	end

	def programs_list_helper(hash)
		if hash.present?
			array = []
			array << 'Advanced Work Class'					if hash.try(:[], :HasAdvancedClassWork) == 'True'
			array << 'Advanced Placement'						if hash.try(:[], :HasAdvancedPlacement) == 'True'
			array << 'Arts' 												if hash.try(:[], :HasArts) == 'True'
			array << 'Dual Enrollment'							if hash.try(:[], :HasDualEnroll) == 'True'
			array << 'Dual Language'								if hash.try(:[], :HasDualLanguage) == 'True'
			array << 'ELL'													if hash.try(:[], :HasELL) == 'True'
			array << 'Health'												if hash.try(:[], :HasHealth) == 'True'
			array << 'Inclusion'										if hash.try(:[], :HasInclusion) == 'True'
			array << 'Internship'										if hash.try(:[], :HasInternship) == 'True'
			array << 'International Baccalaureate'	if hash.try(:[], :HasIntnlBaccalr) == 'True'
			array << 'Phys Education'								if hash.try(:[], :HasPhysicalEd) == 'True'
			array << 'SPED'													if hash.try(:[], :HasSPED) == 'True'
			array << 'STEAM'												if hash.try(:[], :HasSTEAM) == 'True'
			array << 'STEM'													if hash.try(:[], :HasSTEM) == 'True'
			array << 'Tech Focus'										if hash.try(:[], :HasTechFocus) == 'True'
			array << 'Vocational'										if hash.try(:[], :HasVocational) == 'True'
			array << 'World Language'								if hash.try(:[], :HasWorldLanguage) == 'True'
			return array.compact
		else
			return []
		end
	end

	def preview_dates_list_helper(hash)
		if hash.present?
			array = []
			array << hash[:PreviewDate1] 	if hash.try(:[], :PreviewDate1).present?
			array << hash[:PreviewDate2] 	if hash.try(:[], :PreviewDate2).present?
			array << hash[:PreviewDate3] 	if hash.try(:[], :PreviewDate3).present?
			array << hash[:PreviewDate4] 	if hash.try(:[], :PreviewDate4).present?
			array << hash[:PreviewDate5] 	if hash.try(:[], :PreviewDate5).present?
			array << hash[:PreviewDate6] 	if hash.try(:[], :PreviewDate6).present?
			array.compact
		else
			return []
		end
	end

	def partners_list_helper(array)
		if array.present?
			list = []
			array.each do |partner|
				list << "#{partner[:description]}, "
			end
			return list.compact
		else
			return []
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
