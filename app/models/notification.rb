class Notification < ActiveRecord::Base
  attr_accessible :end_time, :message, :start_time, :home_page, :schools_page, :school_choice_pages

  validates :message, presence: true
  validate :start_time_precedes_end_time


  def self.active(ids)
  	if ids.blank?
  		self.where('start_time < ? AND end_time > ?', Time.now, Time.now)
  	else
  		self.where('start_time < ? AND end_time > ? AND id NOT IN (?)', Time.now, Time.now, ids)
  	end
  end

  private

  def start_time_precedes_end_time
  	errors.add(:start_time, "must precede end time") if start_time >= end_time
  end
end
