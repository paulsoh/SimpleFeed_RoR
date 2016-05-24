# require 'spec_helper'
require 'rails_helper'

describe PostsController do
  # ===============================================================
  #
  #                              TEST
  #
  # ===============================================================

  describe '#index' do
    it 'returns 200 response' do
      get :index
      expect(response.status).to eq 200
    end

    it 'renders index template' do
      get :index
      expect(response).to render_template(:index)
    end

    context 'when more than one post' do
      let!(:post_list) { create_list :post, 3 }
      it 'returns an list of posts' do
        get :index
        expect(assigns(:posts)).to eq(post_list)
      end
    end

    context 'when there is one post' do
      let!(:post) { create(:post) }
      it 'returns one post' do
        get :index
        expect(assigns(:posts)).to eq([post])
      end
    end

    context 'when there are no posts' do
      it 'returns empty list(no post)' do
        get :index
        expect(assigns(:posts)).to be_empty 
      end
    end
  end

  describe '#show' do
    let!(:post) {create(:post)}

    context 'when there is post' do
      subject { get :show, id: post.id }
      it 'returns 200 response' do
        subject
        expect(response.status).to eq 200
      end

      it 'renders show template' do
        subject
        expect(response).to render_template(:show)
      end

      it 'returns post with post.id' do
        subject
        expect(assigns(:post).id).to eq post.id
      end
    end

    context 'when post param is invalid' do
      it 'returns record not found error' do
        expect {get :show, id: -1}
        .to raise_exception(ActiveRecord::RecordNotFound)
      end
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
    let!(:post) do 
      create(:post, title: 'Old title', name: 'Old name')
    end

    it 'changes post attributes' do
      put :update, id: post.id, post: { title: 'New title', name: 'New name' }
      post.reload
      expect(post.title).to eq 'New title'
      expect(post.name).to eq 'New name'
    end

    it 'does not accept title less than 4 chars' do
      put :update, id: post.id, post: { title: 'abc', name: 'nil' }
      expect(post.reload.title).not_to eq 'abc'
    end

    it 'redirects to updated post' do
      put :update, id: post.id, post: { title: 'New name', name: 'New name' }
      expect(response).to redirect_to(:post)
    end

    it 're-renders edit method' do
      put :update, id: post.id, post: { title: nil, name: nil }
      expect(response).to render_template(:edit)
    end
  end

  describe '#delete' do
    let!(:post) do 
      create(:post, title: 'test title', name: 'test name')
    end

    it 'deletes post' do
      expect do 
        delete :destroy, id: post.id 
      end.to change(Post, :count).by(-1)
    end

    it 'redirects to index' do
      delete :destroy, id: post.id 
      expect(response).to redirect_to posts_url
    end
  end
end
