class MaterialsController < ApplicationController
  def index
    resp = current_user.person.materials

    resp = Instruction.find(params[:instruction_id]).materials if params[:instruction_id]
    resp = Presentation.find(params[:presentation_id]).materials if params[:presentation_id]
    resp = Answer.find(params[:answer_id]).materials if params[:answer_id]

    resp = resp.where checked: true

    render json: resp
  end

  def new
    material = Material.new key: SecureRandom.uuid, person: current_user.person
    attachable = nil

    if params[:instruction_id]
      attachable = Instruction.find(params[:instruction_id])
    elsif params[:presentation_id]
      attachable = Presentation.find(params[:presentation_id])
    elsif params[:answer_id]
      attachable = Answer.find(param[:answer_id])
    end

    material.attachable = attachable
    material.save!

    obj = get_bucket.object material.key + '/${filename}'
    post = obj.presigned_post

    resp = {fields: post.fields, url: post.url, id: material.id}
    render json: resp
  end

  def update
    material = Material.find params[:id]

    if !material
      render status: 404, body: nil and return
    end

    object = get_bucket.object(material.key + '/' + material.name)

    if !object.exists?
      render status: 404, body: nil and return
    end

    material.name = params[:name]
    material.mime = params[:mime]
    material.checked = true
    material.uploaded_at = DateTime.now
    material.save!

    url = object.presigned_url :get
    resp = {material: material, url: url}
    render json: resp
  end

  def show
    material = Material.find params[:id]

    url = get_bucket.object(material.key + '/' + material.name).presigned_url(:get)
    resp = {material: material, url: url}
    render json: resp
  end

  def destroy
    material = Material.find params[:id]
    object = get_bucket.object material.key + '/' + material.name
    object.delete
    material.delete
  end

  private

  # @return [Bucket]
  def get_bucket
    # noinspection RubyArgCount
    Aws::S3::Resource.new(region: ENV['AWS_REGION']).bucket(ENV['BUCKET_NAME'])
  end
end
