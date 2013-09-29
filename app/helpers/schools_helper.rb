module SchoolsHelper
	def facilities_list_helper(hash)
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
		list << 'Science Lab, ' 				if hash[:hassciencelab] == 'True'
		return list.gsub(/,$/, '')
	end

	def partners_list_helper(array)
		list = ''
		array.each do |partner|
			list << "#{partner[:description]}, "
		end
		return list.gsub(/,$/, '')
	end

	def school_hours_start_time_helper(hours)
		if hours.present?
			start_hour 	= hours.gsub(/am/, '').gsub(/pm/, '').match(/^\d*/).to_s.to_i
			end_hour 		= hours.gsub(/am/, '').gsub(/pm/, '').match(/\d*$/).gsub(/:..$/,'').to_s.to_s
		end
	end

	def school_hours_end_time_helper(hours)
		if hours.present?
			start_hour 	= hours.gsub(/am/, '').gsub(/pm/, '').match(/^\d*/).to_s.to_i
			end_hour 		= hours.gsub(/am/, '').gsub(/pm/, '').match(/\d*$/).gsub(/:..$/,'').to_s.to_s
		end
	end
end
