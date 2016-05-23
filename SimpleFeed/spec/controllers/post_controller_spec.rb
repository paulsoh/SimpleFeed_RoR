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
      expect(assigns(:posts)).to eq([post1, post2])
    end

    it 'returns one post' do
      skip 'Pending implementation, implemented multiple post retrival' 
    end

    it 'returns empty list(no post)' do
      skip 'Pending implementation, implemented multiple post retrival' 
    end
  end

  describe '#show' do
    let!(:post) do 
      create(:post, title: 'New title', name: 'New name', content: 'Content')
    end

    it 'returns 200 response' do
      expect(response.status).to eq 200
    end

    it 'renders show template' do
      get :show, id: post.id
      expect(response).to render_template(:show)
    end

    it 'returns post title' do
      get :show, id: post.id
      expect(assigns(:post).title).to eq 'New title'
    end

    it 'returns post title' do
      get :show, id: post.id
      expect(assigns(:post).name).to eq 'New name'
    end

    it 'returns post content' do
      get :show, id: post.id
      expect(assigns(:post).content).to eq 'Content'
    end
  end

  describe '#create' do
    it 'create new post' do
      expect do
        post :create, post: { title: 'New title', name: 'New name' }
      end.to change(Post, :count).by(1)
    end

    it 'redirect to new post' do
      post :create, post: { title: 'New title', name: 'New name' }
      expect(response).to redirect_to Post.last
    end

    it 'does not create invalid post' do
      expect do
        post :create, post: { title: nil, name: nil }
      end.to_not change(Post, :count)
    end

    it 're-renders new method' do
      post :create, post: { title: nil, name: nil }
      expect(response).to render_template(:new)
    end
  end

  describe '#update' do
    skip
  end

  describe '#delete' do
    skip
  end
end
