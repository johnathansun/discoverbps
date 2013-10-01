class SchoolsController < ApplicationController
  layout :layout_selector

  def home
    @students = Student.where(session_id: session[:session_id])
  end

  def index
    @students = Student.where(session_id: session[:session_id])
    if @students.blank?
      render 'home'
    else
      if params[:student].present? && Student.where(first_name: params[:student], session_id: session[:session_id]).present?
        student = Student.where(first_name: params[:student], session_id: session[:session_id]).first
        session[:current_student_id] = student.id
      end
      street_number = current_student.street_number.present? ? URI.escape(current_student.street_number) : ''
      street_name   = current_student.street_name.present? ? URI.escape(current_student.street_name) : ''
      zipcode       = current_student.zipcode.present? ? URI.escape(current_student.zipcode) : ''
      eligible_schools = bps_api_connector("https://apps.mybps.org/schooldata/schools.svc/GetSchoolChoices?SchoolYear=2013-2014&Grade=03&StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}")[:List]
      @eligible_schools = School.where('bps_id IN (?)', eligible_schools.collect {|x| x[:School]})

      respond_to do |format|
        format.html # index.html.erb
        format.csv do
          require 'csv'
          csv_string = CSV.generate do |csv|
            csv << ['Name', 'Distance', 'Walk Time', 'Drive Time', 'Hours', 'Grades Offered', 'Before School Programs', 'After School Programs', 'Facilities']
                      
            counter = 0
            @eligible_schools.each do |school|
              counter += 1
              csv << [ school.name, '', '', '', school.api_hours.try(:[],0).try(:[], :schhours1), school.api_grades.try(:[], 0).try(:[], :grade), school.api_basic_info.try(:[], 0).try(:[], :BeforeSchPrograms), school.api_basic_info.try(:[], 0).try(:[], :AfterSchPrograms), facilities_list_helper(school.api_facilities[0]) ]
            end
          end

          send_data csv_string,
                    :type => 'text/csv; charset=iso-8859-1; header=present',
                    :disposition => "attachment; filename=#{current_student.first_name}_Schools.csv"
        end
      end
    end
  end

  def show
    @school = School.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @school }
    end
  end

  def print
    @school = School.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @school }
    end
  end

  private

  def bps_api_connector(url)
    response = Faraday.new(:url => url, :ssl => {:version => :SSLv3}).get
    if response.body.present?
      MultiJson.load(response.body, :symbolize_keys => true)
    end
  end

  def layout_selector
    case action_name
    when "home"
      "home"
    else
      "application"
    end
  end

  def facilities_list_helper(hash)
    list = ''
    list << 'Art Room, '            if hash[:hasartroom] == 'True'
    list << 'Athletic Field, '      if hash[:hasathleticfield] == 'True'
    list << 'Auditorium, '          if hash[:hasauditorium] == 'True'
    list << 'Cafeteria, '           if hash[:hascafeteria] == 'True'
    list << 'Computer Lab, '        if hash[:hascomputerlab] == 'True'
    list << 'Gymnasium, '           if hash[:hasgymnasium] == 'True'
    list << 'Library, '             if hash[:haslibrary] == 'True'
    list << 'Music Room, '          if hash[:hasmusicroom] == 'True'
    list << 'Outdoor Classrooms, '  if hash[:hasoutdoorclassroom] == 'True'
    list << 'Playground, '          if hash[:hasplayground] == 'True'
    list << 'Pool, '                if hash[:haspool] == 'True'
    list << 'Science Lab, '         if hash[:hassciencelab] == 'True'
    return list.gsub(/,$/, '')
  end

end
