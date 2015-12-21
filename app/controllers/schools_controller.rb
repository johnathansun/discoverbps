class SchoolsController < ApplicationController
  include ApplicationHelper
  include SchoolsHelper
  layout :layout_selector
  before_filter :load_schools, except: [:print]

  def index
    if current_user_students.blank?
      redirect_to root_url
    else
      current_student.update_column(:step, 2) if current_student.step < 2

      if @home_schools.blank?
        flash[:alert] = 'There were no schools that matched your search. Please try again.'
        redirect_to root_url
      else
        respond_to do |format|
          format.html
          format.csv do
            generate_csv
          end
        end
      end
    end
  end

  def compare
    if current_user_students.blank?
      flash[:alert] = 'There were no schools that matched your search. Please try again.'
      redirect_to root_url
    else
      current_student.update_column(:step, 3) if current_student.step < 3

      @matching_school_ids = current_user_students.collect {|x| x.student_schools.collect {|y| y.bps_id}}.inject(:&)

      if @home_schools.blank?
        flash[:alert] = 'There were no schools that matched your search. Please try again.'
        redirect_to root_url
      else
        respond_to do |format|
          format.html
        end
      end
    end
  end

  def get_ready
    if current_user_students.blank?
      redirect_to root_url
    else
      current_student.update_column(:step, 4) if current_student.step < 4

      if @home_schools.blank?
        flash[:alert] = 'There were no schools that matched your search. Please try again.'
        redirect_to root_url
      else
        respond_to do |format|
          format.html
        end
      end
    end
  end

  def print_lists

  end

  def print
    @school = School.find(params[:id])
    @student_school = StudentSchool.where(id: params[:student_school_id]).try(:first)
  end


  private

    def layout_selector
      case action_name
      when 'print_lists'
        'print'
      when 'print'
        'print'
      else
        'schools'
      end
    end

    def load_schools
      if current_student.present?
        # rank the list if it has already been sorted
        if current_student.student_schools.collect {|x| x.ranked}.any?
          @home_schools = current_student.home_schools.rank(:sort_order)
        #show the stars first if the list had been starred
        elsif current_student.starred_schools.present?
          @home_schools = current_student.starred_schools.all
          current_student.home_schools.rank(:sort_order).all.each do |school|
            @home_schools << school unless @home_schools.include?(school)
          end
        # match the default sort order on the lean page (distance)
        else
          @home_schools = current_student.home_schools.order(:distance)
        end

        @zone_schools = current_student.zone_schools.order(:distance)
        @ell_schools = current_student.ell_schools.order(:distance)
        @sped_schools = current_student.sped_schools.order(:distance)
      else
        @home_schools = nil
        @zone_schools = nil
        @ell_schools = nil
        @sped_schools = nil
      end
    end

    def generate_csv
      require 'csv'
      csv_string = CSV.generate do |csv|

        csv << [current_student.full_name]
        csv << [current_student.formatted_grade_level_name]
        csv << [current_student.full_address]
        csv << ["ELL: #{current_student.ell_language}"]
        csv << ["SPED: #{current_student.sped_needs}"]
        csv << ["AWC: #{current_student.awc_invitation}"]
        csv << []
        csv << ['',
          'Name',
          'Eligibility',
          'Address',
          'Distance from Home',
          'Walk Time',
          'Drive Time',
          'Transportation Eligibility',
          'Hours',
          'Grades Offered',
          'MCAS Tier',
          'Before School Programs',
          'After School Programs',
          'School Focus',
          'Programs',
          'Facilities',
          'Student Support',
          'Partners',
          'Sports',
          'Special Application',
          'Uniform Policy',
          'School Email',
          "#{current_student.formatted_grade_level_name} Demand (#{current_school_year_range})",
          "Open Seats",
          "Applicants",
          "Applicants/Open Seat"

          ]
        csv << []

        if @home_schools.present?
          csv << ['HOME-BASED SCHOOLS']
          csv_row(@home_schools, csv)
        end

        if @zone_schools.present?
          csv << ['ZONE-BASED SCHOOLS']
          csv_row(@zone_schools, csv)
        end

        if @ell_schools.present?
          csv << ['ELL SCHOOLS']
          csv_row(@ell_schools, csv)
        end

        if @sped_schools.present?
          csv << ['SPED SCHOOLS']
          csv_row(@sped_schools, csv)
        end
      end

      send_data csv_string,
                :type => 'text/csv; charset=iso-8859-1; header=present',
                :disposition => "attachment; filename=#{current_student.first_name}s_eligible_schools.csv"

    end

    def csv_row(schools, csv)

      schools.each do |student_school|
        school = student_school.school

        csv << [ '',
          school.name,
          eligibility_helper(student_school.eligibility),
          school.full_address,
          "#{student_school.distance} mi",
          student_school.walk_time,
          student_school.drive_time,
          student_school.transportation_eligibility,
          school.api_hours.try(:[], :Description),
          grade_levels_helper(school.grade_levels),
          school_tier_helper(student_school.tier),
          school.api_surround_care.try(:[], :BeforeSchPrograms),
          school.api_surround_care.try(:[], :AfterSchPrograms),
          school.api_description.try(:[], :schfocus),
          programs_list_helper(school).try(:join, ', '),
          facilities_list_helper(school).try(:join, ', '),
          student_support_list_helper(school).try(:join, ', '),
          partners_list_helper(school).try(:join, ', '),
          sports_list_helper(school).try(:join, ', '),
          school.api_description.try(:[], :specialapplicationnarrative),
          school.api_description.try(:[], :uniformpolicy),
          school.api_basic_info.try(:[], :schemail),
          '',
          school.open_seats(current_student.grade_level),
          school.applicants(current_student.grade_level),
          school.applicants_per_open_seat(current_student.grade_level, last_school_year)
          ]
      end
      csv << []
    end

end
