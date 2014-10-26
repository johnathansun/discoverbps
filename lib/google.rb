module Google

  def self.walk_times(home_latitude, home_longitude, school_coordinates)
    url = "http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{home_latitude},#{home_longitude}&destinations=#{school_coordinates}&mode=walking&units=imperial&sensor=false"
    self.get_results(url)
  end

  def self.drive_times(home_latitude, home_longitude, school_coordinates)
    url = "http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{home_latitude},#{home_longitude}&destinations=#{school_coordinates}&mode=driving&units=imperial&sensor=false"
    self.get_results(url)
  end

  private

  def self.get_results(url)
    escaped_url = URI.escape(url)
    response = Faraday.new(url: escaped_url).get.body
    json_response = MultiJson.load(response, symbolize_keys: true)
    json_response.try(:[], :rows).try(:[], 0).try(:[], :elements)
  end

end
