class TextSnippet < ActiveRecord::Base
	extend FriendlyId
	friendly_id :location, use: :slugged

  attr_accessible :location, :text
end
