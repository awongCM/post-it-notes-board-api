require 'spec_helper'

# TODOs

RSpec.describe 'API::V1:NotesController', :type => :api do
    #initialize test data

    let!(:notes) {create_list(:note, 4)}
    let(:note_id) {notes.first.id}

    describe 'GET v1/notes' do
      before {get '/v1/notes'}

      it 'returns notes' do
        expect(json).not_to be_empty
        expect(json).to eq(4)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

    end

    describe 'GET v1/notes/:id' do
      before { get "/v1/notes/#{note_id}" }
      
      context 'when the note exists' do
        it 'returns the todo' do
          expect(json).not_to be_empty
          expect(json['id']).to eq(note_id)
        end
  
        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end
  
      context 'when the note does not exist' do
        let(:note_id) { 100 }
  
        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end
  
        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Note/)
        end
      end
    end

    describe 'POST v1/notes' do
      let(:valid_attributes) { { title: 'Learn Rails API', content: 'All the Rails API recipes you could ask for', color:'yellow' } }
      
      context 'when the request is valid' do
        before { post '/v1/notes', params: valid_attributes }
  
        it 'creates a note' do
          expect(json['title']).to eq('Learn Elm')
        end
  
        it 'returns status code 201' do
          expect(response).to have_http_status(201)
        end
      end
      
      # TODO - VALIDATION
      # context 'when the request is invalid' do
      #   before { post '/notes', params: { title: 'Foobar' } }
  
      #   it 'returns status code 422' do
      #     expect(response).to have_http_status(422)
      #   end
  
      #   it 'returns a validation failure message' do
      #     expect(response.body)
      #       .to match(/Validation failed: Created by can't be blank/)
      #   end
      # end
    end

    describe 'PUT v1/notes/:id' do
      let(:valid_attributes) { { title: 'Shopping' } }
      
      context 'when the record exists' do
        before { put "/v1/notes/#{note_id}", params: valid_attributes }
  
        it 'updates the record' do
          expect(response.body).to be_empty
        end
  
        it 'returns status code 204' do
          expect(response).to have_http_status(204)
        end
      end
    end

    describe 'DELETE v1/notes/:id' do
      before { delete "/v1/notes/#{note_id}" }
      
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

end
