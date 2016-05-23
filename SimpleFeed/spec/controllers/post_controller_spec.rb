# require 'spec_helper'
require 'rails_helper'

describe PostsController do
  describe '#index' do
    it 'returns 200 response' do
      expect(response.status).to eq 200
    end

    it 'renders index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'returns an list of posts' do
      skip
    end

    it 'returns one post' do
      skip
    end

    it 'returns empty list(no post)' do
      skip
    end
  end

  describe '#show' do
    let!(:post) { create(:post) }

    it 'returns 200 response' do
      expect(response.status).to eq 200
    end

    it 'renders show template' do
      get :show, id: post.id
      expect(response).to render_template(:show)
    end
    
  end
end
