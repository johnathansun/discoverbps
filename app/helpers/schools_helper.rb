module SchoolsHelper
	def facilities_list_helper(hash)
		if hash.present?
			list = []
			list << 'Art Room' 						if hash[:hasartroom] == 'True'
			list << 'Athletic Field' 			if hash[:hasathleticfield] == 'True'
			list << 'Auditorium' 					if hash[:hasauditorium] == 'True'
			list << 'Cafeteria' 					if hash[:hascafeteria] == 'True'
			list << 'Computer Lab' 				if hash[:hascomputerlab] == 'True'
			list << 'Gymnasium' 					if hash[:hasgymnasium] == 'True'
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

	def sports_list_helper(hash)
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

	def health_list_helper(hash)
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

	def uniform_policy_list_helper(hash)
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

	def enrollment_list_helper(hash)
		if hash.present?
			list = []
			list << hash[:SchSize]
			return list
		else
			return nil
		end
	end


	def school_type_helper(hash)
		if hash.present?
			list = ''
			list += 'District, ' if hash[:isdistrict] == 'True'
			list += 'Charter, ' if hash[:ischarter] == 'True'
			list += 'Citywide,' if hash[:iscitywide] == 'True'
			list += 'Pilot' if hash[:ispilot] == 'True'
			return list.gsub(/,\s$/, '')
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

	def grade_levels_data_helper(grade_levels)
		tags = []
		tags << 'Early Learning Center' if (grade_levels & ['K0', 'K1', 'K2']).present?
		tags << 'K-5' if (grade_levels & ['K0', 'K1', 'K2', '1', '2', '3', '4', '5']).present?
		tags << 'K-8' if (grade_levels & ['K0', 'K1', 'K2', '1', '2', '3', '4', '5', '6', '7', '8']).present?
		tags << '6-8' if (grade_levels & ['6', '7', '8']).present?
		tags << '6-12' if (grade_levels & ['6', '7', '8', '9', '10', '11', '12']).present?
		tags << '7-12 (Exam School only)' if (grade_levels & ['7', '8', '9', '10', '11', '12']).present?
		tags << '9-12' if (grade_levels & ['9', '10', '11', '12']).present?
		return tags
	end

	def preference_category_tags_helper(category, school)
		preference_names = category.preferences.collect {|x| x.name}
		
		if category.name == 'Grades Offered'
			tags = grade_levels_data_helper(school.grade_levels)
		
		elsif category.name == 'Facility Features'
			tags = facilities_list_helper(school.api_facilities[0])
		
		elsif category.name == 'Sports'
			tags = sports_list_helper(school.api_sports[0])
		
		elsif category.name == 'Health & Wellness'
			tags = health_list_helper(school.api_basic_info.try(:[], 0))
		
		elsif category.name == 'Enrollment'
			tags = enrollment_list_helper(school.api_basic_info.try(:[], 0))

		elsif category.name == 'Uniform Policy'
			tags = uniform_policy_list_helper(school.api_description[0])
		end
		
		return tags
	end

	# def link_to_add_student(link_name, partial)
 #    new_object = .page_fields.new
 #    id = new_object.object_id
 #    fields = f.fields_for('page_fields_attributes[]', new_object, index: id) do |builder|
 #      render :partial => partial, locals: {f: builder, object: new_object}
 #    end
 #    return link_to(link_name, '#', class: 'add_fields btn btn-small btn-success', data: {id: id, fields: fields.gsub('\n', '')})
 #  end
end
