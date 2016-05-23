# require 'spec_helper'
require 'rails_helper'

describe PostsController do
  # ===============================================================
  #
  #                              TEST
  #
  # ===============================================================

  describe '#index' do
    let!(:post1) { create(:post) }
    let!(:post2) { create(:post) }

    it 'returns 200 response' do
      expect(response.status).to eq 200
    end

    it 'renders index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'returns an list of posts' do
      get :index
      puts(assigns)
      expect(assigns(:posts).length).to eq([post1, post2].length)
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

  describe '#create' do
    skip
  end

  describe '#new' do
    skip
  end

  describe '#edit' do
    skip
  end

  describe '#update' do
    skip
  end

  describe '#delete' do
    skip
  end
end
