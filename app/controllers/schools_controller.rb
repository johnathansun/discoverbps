class SchoolsController < ApplicationController
  include SchoolsHelper
  layout :layout_selector

  def index
    if current_user_students.blank?
      redirect_to root_url
    else
      current_student.update_column(:step, 2) if current_student.step < 2

      # rank the list if it has already been sorted
      if current_student.student_schools.collect {|x| x.ranked}.any?
        home_schools = current_student.home_schools.rank(:sort_order)
      #show the stars first if the list had been starred
      elsif current_student.starred_schools.present?
        home_schools = current_student.starred_schools.all
        current_student.home_schools.rank(:sort_order).all.each do |school|
          home_schools << school unless home_schools.include?(school)
        end
      # match the default sort order on the lean page (distance)
      else
        home_schools = current_student.home_schools.order(:distance)
      end

      @home_schools = home_schools
      @zone_schools = current_student.zone_schools.order(:distance)
      @ell_schools = current_student.ell_schools.order(:distance)
      @sped_schools = current_student.sped_schools.order(:distance)

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

  def compare
    if current_user_students.blank?
      flash[:alert] = 'There were no schools that matched your search. Please try again.'
      redirect_to root_url
    else
      current_student.update_column(:step, 3) if current_student.step < 3

      # rank the list if it has already been sorted
      if current_student.student_schools.collect {|x| x.ranked}.any?
        home_schools = current_student.home_schools.rank(:sort_order)
      #show the stars first if the list had been starred
      elsif current_student.starred_schools.present?
        home_schools = current_student.starred_schools.all
        current_student.home_schools.rank(:sort_order).all.each do |school|
          home_schools << school unless home_schools.include?(school)
        end
      # match the default sort order on the lean page (distance)
      else
        home_schools = current_student.home_schools.order(:distance)
      end

      @home_schools = home_schools
      @zone_schools = current_student.zone_schools.order(:distance)
      @ell_schools = current_student.ell_schools.order(:distance)
      @sped_schools = current_student.sped_schools.order(:distance)

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

      # rank the list if it has already been sorted
      if current_student.student_schools.collect {|x| x.ranked}.any?
        home_schools = current_student.home_schools.rank(:sort_order)
      #show the stars first if the list had been starred
      elsif current_student.starred_schools.present?
        home_schools = current_student.starred_schools.all
        current_student.home_schools.rank(:sort_order).all.each do |school|
          home_schools << school unless home_schools.include?(school)
        end
      # match the default sort order on the lean page (distance)
      else
        home_schools = current_student.home_schools.order(:distance)
      end

      @home_schools = home_schools
      @zone_schools = current_student.zone_schools.order(:distance)
      @ell_schools = current_student.ell_schools.order(:distance)
      @sped_schools = current_student.sped_schools.order(:distance)

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

  def print_home_schools
    @home_schools = current_student.home_schools
  end

  # POST
  def sort
    key = params.keys.first
    student = Student.find(key)
    if student.present?
      params[key].flatten.each_with_index do |bps_id, i|
        student_school = student.student_schools.where(bps_id: bps_id).first
        if student_school.present?
          student_school.update_attributes(sort_order_position: i, ranked: true)
        end
      end
    end
  end

  private

    def layout_selector
      case action_name
      when 'print_home_schools'
        'print'
      when 'print_zone_schools'
        'print'
      when 'print'
        'print'
      else
        'schools'
      end
    end

end
