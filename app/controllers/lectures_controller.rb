class LecturesController < ApplicationController
  def index
    lectures = Lecture.includes(instructions: :people).where(people: {email: current_person.email})
    lectures = Lecture.all if current_person.all

    render json: lectures
  end

  def create
    lecture = Lecture.new name: params[:name], code: params[:code], workload: [:workload]
    lecture.save!
    render json: lecture
  end

  def show
    render json: Lecture.find(params[:id])
  end

  def update
    render plain: 'I update one entity'
  end

  def destroy
    render json: Lecture.find(params[:id]).destroyLecture
  end
end
