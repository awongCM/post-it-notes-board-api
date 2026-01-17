module API::V1
  class NotesController < ApplicationController
    before_action :set_note, only: [:show, :update, :destroy]

    def index
      @notes = Note.order('created_at DESC')
      render json: @notes
    end

    def show
      render json: @note
    end

    def create
      @note = Note.new(note_params)
      if @note.save
        render json: @note, status: :created
      else
        render json: @note.errors, status: :unprocessable_entity
      end
    end

    def update
      if @note.update(note_params)
        head :no_content
      else
        render json: @note.errors, status: :unprocessable_entity
      end
    end

    def destroy
      if @note.destroy
        head :no_content
      else
        render json: @note.errors, status: :unprocessable_entity
      end
    end

    private

    def set_note
      @note = Note.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Couldn't find Note with 'id'=#{params[:id]}" }, status: :not_found
    end

    def note_params
      params.require(:note).permit(:title, :content, :color, :x_coordinate, :y_coordinate)
    end

  end
end