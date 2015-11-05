class AdminMailer < ActionMailer::Base

  def api_error(endpoint, sync_method, params, bps_id)
    @endpoint = endpoint
    @sync_method = sync_method
    @params = params
    @school = School.where(bps_id: bps_id).first

    mail(to: ["joelmahoney@gmail.com", "bavery@bostonpublicschools.org", "ehankwitz@bostonpublicschools.org", "dganesan@bostonpublicschools.org"], from: "errors@discoverbps.org", subject: "API Error")
  end

end