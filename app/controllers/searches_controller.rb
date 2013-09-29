class SearchesController < ApplicationController
  
  def create
    @search = Search.new(params[:search])
    
    respond_to do |format|
      if @search.save
      	street_number = URI.escape(params[:search][:street_number].try(:strip))
        street_name   = URI.escape(params[:search][:street_name].try(:strip))
        zipcode       = URI.escape(params[:search][:zipcode].try(:strip))
        
        @addresses = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSDEV/schools.svc/GetAddressMatches?StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}")[:List]
        
        format.js { render template: "searches/address_verification" }
      else
        format.js { render template: "searches/errors" }
      end
    end
  end

  def address_verification
    @search = Search.find(params[:id])
    
    respond_to do |format|
      if @search.update_attributes(params[:search])
        format.js { render template: "searches/iep" }         
      else
        format.js { render template: "searches/errors" }
      end
    end
  end

  def iep
    @search = Search.find(params[:id])
    
    respond_to do |format|
      if @search.update_attributes(params[:search])
        format.js { render template: "searches/ell" }         
      else
        format.js { render template: "searches/errors" }
      end
    end
  end

  def ell
    @search = Search.find(params[:id])
    
    respond_to do |format|
      if @search.update_attributes(params[:search])
        format.js { render template: "searches/preferences" }         
      else
        format.js { render template: "searches/errors" }
      end
    end
  end

  def preferences
    @search = Search.find(params[:id])
    
    respond_to do |format|
      if @search.update_attributes(params[:search])
      	street_number = @search.street_number.present? ? URI.escape(@search.street_number) : ''
    		street_name   = @search.street_name.present? ? URI.escape(@search.street_name) : ''
    		zipcode       = @search.zipcode.present? ? URI.escape(@search.zipcode) : ''

    eligible_schools = bps_api_connector("https://apps.mybps.org/schooldata/schools.svc/GetSchoolChoices?SchoolYear=2013-2014&Grade=03&StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}")[:List]

    # GET school information
    @schools = School.where('bps_id IN (?)', eligible_schools.collect {|x| x[:School]})
    
    respond_to do |format|
      format.js { render action: "schools/index" }  
    end        
      else
        format.js { render template: "searches/errors" }
      end
    end
  end

  private

  def bps_api_connector(url)
    response = Faraday.new(:url => url, :ssl => {:version => :SSLv3}).get
    if response.body.present?
      MultiJson.load(response.body, :symbolize_keys => true)
    end
  end
end
