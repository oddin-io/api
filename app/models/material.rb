# == Schema Information
#
# Table name: materials
#
#  id       :integer          not null, primary key
#  name     :string(50)       not null
#  mime     :string(50)       not null
#  file_url :text             not null
#

class Material < ActiveRecord::Base
  has_and_belongs_to_many :instructions
  has_and_belongs_to_many :presentations
  has_and_belongs_to_many :answers

  validates :name, :mime, :file_url, presence: true
end
