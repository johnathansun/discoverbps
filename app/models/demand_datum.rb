class DemandDatum < ActiveRecord::Base
  belongs_to :school
  attr_accessible :school_id, :bps_id, :year, :grade_level, :seats_before_round, :seats_after_round, :total_seats,
                  :first_choice_applicants, :second_choice_applicants, :third_choice_applicants, :total_applicants, :applicants_per_open_seat

  before_save :set_total_applicants_if_blank!
  before_save :calculate_applicants_per_open_seat!

  validates :school_id, :grade_level, presence: true

  private

  def set_total_applicants_if_blank!
    if self.total_applicants.blank? && self.first_choice_applicants.present? && self.second_choice_applicants.present? && self.third_choice_applicants.present?
      self.total_applicants = self.first_choice_applicants.to_i + self.second_choice_applicants.to_i + self.third_choice_applicants.to_i
    else
      nil
    end
  end

  def calculate_applicants_per_open_seat!
    if self.total_applicants.present? && self.seats_before_round.present?
      if self.total_applicants == 0 || self.seats_before_round == 0
        count = 0
      else
        count = (self.total_applicants.to_f / self.seats_before_round.to_f)
      end
    else
      count = nil
    end
    self.applicants_per_open_seat = count.try(:round, 1)
  end
end
