# require 'spec_helper'
require 'rails_helper'

describe PostsController do
  # ===============================================================
  #
  #                         SHARED EXAMPLES
  #
  # =============================================================== 

  shared_examples 'single param update' do |params, fmt|
    let!(:post) { create(:post) }
    it "updates post #{params.keys[0]} field" do
      put :update, id: post.id, post: params, format: fmt ||= :html
      expect(post.reload.send(params.keys[0]))
      .to eq params.values[0]
    end

    if fmt == :json
      it 'returns 204 status code' do
        put :update, id: post.id, post: params, format: fmt
        expect(response.status).to eq 204
      end
    else
      it 'redirects to updated post' do
        put :update, id: post.id, post: params
        expect(response).to redirect_to(:post)
      end
    end
  end

  shared_examples 'fails to create post with invalid params' do |params, fmt|
    it "does not create post with invalid #{params.keys[0]}" do
      expect do
        post :create, post: attributes_for(:post, params), format: fmt ||= :html
      end.to_not change(post, :count)
    end

    if fmt == :json
      it "post with invalid #{params.keys[0]} returns status 422" do
        post :create, post: attributes_for(:post, params), format: fmt
        expect(response.status).to eq 422
      end
    end
  end

  shared_examples 'invalid single param update' do |params, fmt|
    let!(:post) { create(:post) }
    it "updates post with invalid #{params.keys[0]} field" do
      put :update, id: post.id, post: params, format: fmt ||= :html
      expect(post.reload.send(params.keys[0]))
      .to eq post.send(params.keys[0])
    end

    if fmt == :json
      it "update with invalid #{params.keys[0]} returns 422 status code" do
        put :update, id: post.id, post: params, format: fmt
        expect(response.status).to eq 422
      end
    else
      it "update with invalid #{params.keys[0]} re-renders edit view" do
        put :update, id: post.id, post: params, format: fmt
        expect(response).to render_template(:edit)
      end
    end
  end

  shared_examples 'return error message' do |msg|
    it "return error message: #{msg}" do
      subject
      expect(json['error'])
      .to eq msg 
    end
  end

  shared_examples 'delete post from DB' do
    it 'deletes post from DB' do
      expect { subject }
      .to change(Post, :count).by(-1)
    end
  end

  shared_examples 'redirect_to :index' do
    it 'redirect to :index view' do
      subject
      expect(response).to redirect_to posts_url
    end
  end

  shared_examples 'assigns list of posts' do |n|
    let!(:post_list) { create_list :post, n }
    it "assigns list of #{n} post(s)" do
      subject
      expect(assigns(:posts)).to eq(post_list)
    end
  end

  shared_examples 'returns list of posts' do |n|
    let!(:post_list) { create_list :post, n }
    it "response returns #{n} post(s)" do
      subject
      expect(response.body).to eq(post_list.to_json)
    end
  end

  shared_examples 'assigns post with post.id' do
    it 'assigns post with post.id' do
      subject
      expect(assigns(:post).id).to eq post.id
    end
  end

  shared_examples 'returns post with post.id' do
    it 'returns post with post.id' do
      subject
      expect(json['id']).to eq post.id
    end
  end

  shared_examples 'create new post to DB' do
    it 'creates new post to DB' do
      expect { subject }
      .to change(Post, :count).by(1)
    end
  end

  shared_examples 'redirect_to new post' do
    it 'redirect_to new post' do
      subject
      expect(response).to redirect_to Post.last
    end
  end
  
  shared_examples 'fails to create post with invalid params' do |params, fmt|
    it "does not create post with invalid #{params.keys[0]}" do
      expect do
        post :create, post: attributes_for(:post, params), format: fmt ||= :html
      end.to_not change(Post, :count)
    end

    if fmt == :json
      it "post with invalid #{params.keys[0]} returns status 422" do
        post :create, post: attributes_for(:post, params), format: fmt
        expect(response.status).to eq 422
      end
    end
  end

  # ===============================================================
  #
  #                              TEST
  #
  # ===============================================================

  describe '#index' do
    context 'with html request' do
      subject { get :index }
      include_examples 'renders 200 http status code'
      include_examples 'renders template', :index

      context 'when there is more than one posts' do
        include_examples 'assigns list of posts', 3
      end
      context 'when there is one post' do
        include_examples 'assigns list of posts', 1 
      end
      context 'when there is no posts' do
        include_examples 'assigns list of posts', 0 
      end
    end

    context 'with json request' do
      subject { get :index, format: :json }
      include_examples 'renders 200 http status code'

      context 'when there is more than one post' do
        include_examples 'returns list of posts', 3 
      end
      context 'when there is one post' do
        include_examples 'returns list of posts', 1 
      end
      context 'when there are no posts' do
        include_examples 'returns list of posts', 0
      end
    end
  end

  describe '#show' do
    describe 'html format' do
      let!(:post) {create(:post)}
      context 'when param is valid and post exists' do
        subject { get :show, id: post.id }
        include_examples 'renders 200 http status code'
        include_examples 'renders template', :show
        include_examples 'assigns post with post.id'
      end

      context 'when param is valid and post does not exist' do
        subject { get :show, id: Post.last.id + 1 }
        include_examples 'redirect_to :index'
      end

      context 'when param is invalid' do
        subject { get :show, id: -1 }
        include_examples 'redirect_to :index'
      end
    end

    describe 'json format' do
      let!(:post) {create(:post)}
      context 'when param is valid and post exists' do
        subject { get :show, id: post.id, format: :json }
        include_examples 'renders 200 http status code'
        include_examples 'returns post with post.id'
      end

      context 'when param is valid and post does not exist' do
        subject { get :show, id: Post.last.id + 1, format: :json }
        include_examples 'renders 404 http status code'
        include_examples 'return error message', 'Post not found' 
      end

      context 'when param is invalid' do
        subject { get :show, id: -1, format: :json }
        include_examples 'renders 404 http status code'
        include_examples 'return error message', 'Post not found' 
      end
    end
  end

  describe '#create' do
    describe 'html format' do
      context 'when post create success' do
        subject { post :create, post: attributes_for(:post) }
        include_examples 'create new post to DB'
        include_examples 'redirect_to new post'
      end

      context 'when post create fails' do
        include_examples(
          'fails to create post with invalid params', title: 'paul'
        )
        include_examples(
          'fails to create post with invalid params', name: nil
        )
        it 're-renders new method' do
          post :create, post: { title: nil, name: nil }
          expect(response).to render_template(:new)
        end
      end
    end

    describe 'json format' do
      context 'when post create success' do
        subject { post :create, post: attributes_for(:post), format: :json }
        include_examples 'create new post to DB'
        include_examples 'renders 201 http status code'
      end

      context 'when post create fails' do
        include_examples(
          'fails to create post with invalid params', { title: 'paul' }, :json
        )
        include_examples(
          'fails to create post with invalid params', { name: nil }, :json
        )
      end
    end
  end

  describe '#update' do
    describe 'html format' do
      context 'when post update success' do
        include_examples 'single param update', title: 'Update title'
        include_examples 'single param update', name: 'Update name'  
        include_examples 'single param update', content: 'Update content'
      end

      context 'when post update fails' do
        include_examples 'invalid single param update', title: 'abc'
        include_examples 'invalid single param update', name: nil
      end
    end
    describe 'json format' do
      context 'when post update success' do
        include_examples( 
          'single param update', { title: 'Update title' }, :json
        )
        include_examples( 
          'single param update', { name: 'Update name' }, :json
        )
        include_examples( 
          'single param update', { content: 'Update content' }, :json
        )
      end

      context 'when post update fails' do
        context 'due to invalid params' do
          include_examples 'invalid single param update', { title: 'ab' }, :json
          include_examples 'invalid single param update', { name: nil }, :json
        end

        context 'due to invalid id' do
          let!(:post) { create(:post) }
          subject { put :update, id: Post.last.id + 1, format: :json }
          include_examples 'renders 404 http status code'
          include_examples 'return error message', 'Post not found'
        end
      end
    end
  end

  describe '#delete' do
    describe 'html format' do
      let!(:post) {create(:post)}
      context 'when param is valid and post exists' do
        subject { delete :destroy, id: post.id }
        context 'successfully delete post' do
          include_examples 'delete post from DB'
          include_examples 'redirect_to :index'
        end
      end
      context 'when param is invalid' do
        context 'delete post fails' do
          subject { delete :destroy, id: Post.last.id + 1 }
          include_examples 'redirect_to :index'
        end
      end
    end

    describe 'json format' do
      let!(:post) {create(:post)}
      context 'when param is valid and post exists' do
        subject { delete :destroy, id: post.id, format: :json }
        context 'successfully delete post' do
          include_examples 'delete post from DB'
          include_examples 'renders 204 http status code'
        end
      end
      context 'when param is invalid' do
        subject { delete :destroy, id: Post.last.id + 1, format: :json }
        context 'delete post fails' do
          include_examples 'renders 404 http status code'
          include_examples 'return error message', 'Post not found'
        end
      end
    end
  end
end
