class AdminMailer < ActionMailer::Base

  def api_error(endpoint, params, bps_id)
    @endpoint = endpoint
    @params = params
    @school = School.where(bps_id: bps_id).first

    mail(to: ["joelmahoney@gmail.com", "bavery@bostonpublicschools.org", "ehankwitz@bostonpublicschools.org", "dganesan@bostonpublicschools.org"], from: "errors@discoverbps.org", subject: "API Error")
  end

end