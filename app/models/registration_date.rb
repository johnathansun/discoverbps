class RegistrationDate < ActiveRecord::Base
  attr_accessible :start_date, :end_date, :name

  validates :name, :start_date, presence: true
  validates :name, uniqueness: true
end
