class LecturesController < ApplicationController
  def index
    render json: Lecture.all
  end

  def new
    render plain: 'I display a form for creating new entity'
  end

  def create
    lecture = Lecture.new name: params[:name], code: params[:code], workload: [:workload]
    lecture.save!
    render json: lecture
  end

  def show
    render json: Lecture.find(params[:id])
  end

  def edit
    render plain: 'I display a form for editing an entity'
  end

  def update
    render plain: 'I update one entity'
  end

  def destroy
    render plain: 'I destroy one entity'
  end
end
