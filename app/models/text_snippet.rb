class TextSnippet < ActiveRecord::Base
	extend FriendlyId
	friendly_id :location, use: :slugged

  attr_accessible :location, :text

	def text?
		self.text.html_safe
	end

	def self.find(obj)
		friendly.find(obj)
	end
end
