class User < ActiveRecord::Base
  attr_accessible :name, :location, :age, :gender, :height

  scope :me, -> { where(name: "Brian Quaranto").first }
end
