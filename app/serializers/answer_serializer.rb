# == Schema Information
#
# Table name: answers
#
#  id          :integer          not null, primary key
#  text        :string(140)      not null
#  anonymous   :boolean          default(FALSE), not null
#  accepted    :boolean          default(FALSE)
#  created_at  :datetime         not null
#  question_id :integer          not null
#  person_id   :integer          not null
#

class AnswerSerializer < ActiveModel::Serializer
  attributes :id, :text, :anonymous, :created_at, :accepted

  has_one :question
  has_one :person
end
