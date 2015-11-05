class AdminMailer < ActionMailer::Base

  def api_error(endpoint, bps_id)
    @endpoint = endpoint
    @bps_id = bps_id

    mail(to: "joelmahoney@gmail.com", from: "errors@discoverbps.org", subject: "API Error")
  end

end