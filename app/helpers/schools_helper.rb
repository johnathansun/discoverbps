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
			list << 'Science Lab, ' 				if hash[:hassciencelab] == 'True'
			return list.gsub(/,\s$/, '')
		else
			return ''
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

	def partners_list_helper(array)
		if array.present?
			list = ''
			array.each do |partner|
				list << "#{partner[:description]}, "
			end
			return list.gsub(/,\s?$/, '')
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
		raw string.try(:gsub, /\s/, '&nbsp;mi')
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
