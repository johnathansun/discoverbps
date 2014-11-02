class Admin::DemandDataController < ApplicationController
  before_filter :authenticate_admin!
  layout 'admin'

  def index
    @demand_data = DemandDatum.all
  end

  def new
    @demand_datum = DemandDatum.new
  end

  def create

    CSV.foreach(params[:file].path, headers: true) do |row|

      school = School.where(bps_id: row[0]).first
      year = row[2].try(:strip).try(:gsub, /\-.*/, '').try(:strip)
      grade = row[3].try(:strip).try(:gsub, /^0/, '').try(:upcase)

      if school.present? && year.present? && grade.present? && row[4].present? && (row[10].present? || (row[7].present? && row[8].present? && row[9].present?))
        DemandDatum.create(school_id: school.id, bps_id: row[0], year: year, grade_level: grade, seats_before_round: row[4], seats_after_round: row[5], total_seats: row[6], first_choice_applicants: row[7], second_choice_applicants: row[8], third_choice_applicants: row[9], total_applicants: row[10])
      end
    end

    respond_to do |format|
      format.html { redirect_to admin_demand_data_url, notice: 'Demand Data was successfully uploaded.' }
    end
  end

  def edit
    @demand_datum = DemandDatum.find(params[:id])
  end

  def update
    @demand_datum = DemandDatum.find(params[:id])

    respond_to do |format|
      if @demand_datum.update_attributes(params[:demand_datum])
        format.html { redirect_to admin_demand_data_url, notice: 'Demand Data was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @demand_datum = DemandDatum.find(params[:id])
    @demand_datum.destroy

    respond_to do |format|
      format.html { redirect_to admin_demand_data_url }
    end
  end

  def delete_all
    DemandDatum.delete_all

    respond_to do |format|
      format.html { redirect_to admin_demand_data_url }
    end
  end
end
