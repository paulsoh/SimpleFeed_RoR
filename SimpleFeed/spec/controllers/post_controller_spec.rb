# encoding: utf-8
# require 'spec_helper'
require 'rails_helper'

describe PostsController do
  # ===============================================================
  #
  #                         SHARED EXAMPLES
  #
  # =============================================================== 

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

  shared_examples 'single field update' do |params|
    it "updates post #{params.keys[0]} field" do
      subject
      expect(post.reload.send(params.keys[0]))
      .to eq params.values[0]
    end
  end

  shared_examples 'invalid single field update' do |params|
    it "does not update post with invalid #{params.keys[0]} field" do
      subject
      expect(post.reload.send(params.keys[0]))
      .to eq post.send(params.keys[0])
    end
  end

  shared_examples 'fails to create with invalid params' do
    it 'does not create post with invalid field' do
      expect { subject }.to change(Post, :count).by(0)
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

  shared_examples 'redirect_to index' do
    it 'redirect to index view' do
      subject
      expect(response).to redirect_to posts_url
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
    let!(:post) {create(:post)}
    context 'with html request' do
      context 'when param is valid and post exists' do
        subject { get :show, id: post.id }
        include_examples 'renders 200 http status code'
        include_examples 'renders template', :show
        include_examples 'assigns post with post.id'
      end

      context 'when param is valid and post does not exist' do
        subject { get :show, id: Post.last.id + 1 }
        include_examples 'redirect_to index'
      end

      context 'when param is invalid' do
        subject { get :show, id: -1 }
        include_examples 'redirect_to index'
      end
    end

    context 'with json request' do
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
    context 'with html request' do
      context 'when post create succeeds' do
        subject { post :create, post: attributes_for(:post) }
        include_examples 'create new post to DB'
        include_examples 'redirect_to new post'
      end

      context 'when post create fails' do
        context 'with invalid title length' do
          subject { post :create, post: attributes_for(:post, :short_title) }
          include_examples 'fails to create with invalid params'
        end
        context 'with blank name field' do
          subject { post :create, post: attributes_for(:post, :invalid_name) }
          include_examples 'fails to create with invalid params'
        end
        context 'with invalid keywords in title field' do
          subject { post :create, post: attributes_for(:post, :invalid_title) }
          include_examples 'fails to create with invalid params'
        end
        context 'when title or name is identical to previous post' do
          let!(:posts) {create(:post)}
          subject do 
            post :create, post: { title: Post.last.title, name: Post.last.name }
          end
          include_examples 'fails to create with invalid params'
          it 'duplicated title returns custom error message' do
            subject
            expect(assigns['post'].errors.full_messages)
            .to include('Title identical to last post')
          end
          it 'duplicated name returns custom error message' do
            subject
            expect(assigns['post'].errors.full_messages)
            .to include('Name identical to last post')
          end
        end
        
        it 're-renders new method' do
          post :create, attributes_for(:post, :invalid_post)
          expect(response).to render_template(:new)
        end
      end
    end

    context 'with json request' do
      context 'when post create succeeds' do
        subject { post :create, post: attributes_for(:post), format: :json }
        include_examples 'create new post to DB'
        include_examples 'renders 201 http status code'
      end

      context 'when post create fails' do
        context 'with invalid title length' do
          subject do 
            post :create, 
                 post: attributes_for(:post, :short_title), 
                 format: :json
          end
          include_examples 'fails to create with invalid params'
        end
        context 'with blank name field' do
          subject do 
            post :create, 
                 post: attributes_for(:post, :invalid_name), 
                 format: :json
          end
          include_examples 'fails to create with invalid params'
        end
        context 'with invalid keywords in title field' do
          subject do 
            post :create, 
                 post: attributes_for(:post, :invalid_title), 
                 format: :json
          end
          include_examples 'fails to create with invalid params'
        end
        context 'when title or name is identical to previous post' do
          let!(:posts) {create(:post)}
          subject do 
            post :create, 
                 post: { title: Post.last.title, name: Post.last.name },
                 format: :json
          end
          include_examples 'fails to create with invalid params'
          it 'duplicated title returns custom error message' do
            subject
            expect(json['title']).to include 'identical to last post'
          end
          it 'duplicated name returns custom error message' do
            subject
            expect(json['name']).to include 'identical to last post'
          end
        end
        it 'returns 422 http status code ' do
          post :create, 
               post: attributes_for(:post, :invalid_post), 
               format: :json
          expect(response).to have_http_status 422 
        end
      end
    end
  end

  describe '#update' do
    context 'with html request' do
      let(:post) { create :post }
      context 'when post update params are valid' do
        subject do
          put :update, 
              id: post.id, 
              post: { title: 'Update', name: 'Update' }, 
              format: :html
        end
        context 'with title and name field update' do
          include_examples 'single field update', title: 'Update'
          include_examples 'single field update', name: 'Update'
        end
        it 'redirects do updated post' do
          subject
          expect(response).to redirect_to :post
        end
      end
      context 'when post update params are invalid' do
        context 'with invalid title length update' do
          subject do
            put :update, id: post.id, post: { title: 'abc' }, format: :html
          end
          include_examples 'invalid single field update', title: 'abc'
        end
        context 'with invalid title keyword update' do
          subject do
            put :update, id: post.id, post: { title: '광고' }, format: :html
          end
          include_examples 'invalid single field update', title: '광고'
        end
        context 'with blank name field update' do
          subject do
            put :update, id: post.id, post: { name: nil }, format: :html
          end
          include_examples 'invalid single field update', name: nil
        end
        it 'redirects do edit view' do
          put :update, id: post.id, post: { title: 'abc' }, format: :html
          expect(response).to render_template(:edit)
        end
      end
    end
    context 'with json request' do
      let(:post) { create :post }
      context 'when post update params are valid' do
        context 'with title and name field update' do
          subject do
            put :update, 
                id: post.id, 
                post: { title: 'Update', name: 'Update' }, 
                format: :json
          end
          include_examples 'single field update', title: 'Update'
          include_examples 'single field update', name: 'Update'
        end
        it 'returns 204 http status code ' do
          put :update, 
              id: post.id, 
              post: { title: 'Update', name: 'Update' }, 
              format: :json
          expect(response).to have_http_status 204 
        end
      end
      context 'when post update params are invalid' do
        context 'with invalid title length update' do
          subject do
            put :update, id: post.id, post: { title: 'abc' }, format: :json
          end
          include_examples 'invalid single field update', title: 'abc'
        end
        context 'with invalid title keyword update' do
          subject do
            put :update, id: post.id, post: { title: '광고' }, format: :json
          end
          include_examples 'invalid single field update', title: '광고'
        end
        context 'with blank name field update' do
          subject do
            put :update, id: post.id, post: { name: nil }, format: :json
          end
          include_examples 'invalid single field update', name: nil
        end
        it 'returns 422 http status code ' do
          put :update, id: post.id, post: { title: '광고' }, format: :json
          expect(response).to have_http_status 422 
        end
      end
    end
  end

  describe '#delete' do
    let!(:post) {create(:post)}
    context 'with html request' do
      context 'when param is valid and post exists' do
        subject { delete :destroy, id: post.id }
        context 'successfully delete post' do
          include_examples 'delete post from DB'
          include_examples 'redirect_to index'
        end
      end
      context 'when param is invalid' do
        subject { delete :destroy, id: Post.last.id + 1 }
        context 'delete post fails and redirects to index' do
          include_examples 'redirect_to index'
        end
      end
    end

    context 'with json request' do
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

  describe '#search' do
    let!(:posts) {create_list :post, 5}
    let!(:unique_post) {create :post, :unique_post}
    context 'when there is more than one result' do
      include_examples 'renders 200 http status code'
      context 'when there is one result' do
        subject { get :search, keyword: 'Unique' }
        it 'returns 1 search result' do
          subject
          expect(assigns['posts']).to eq [unique_post]
        end
        include_examples 'renders template', :search
      end
      context 'when there is more than one result' do
        subject { get :search, keyword: 'title' }
        it 'returns 5 search result' do
          subject
          expect(assigns['posts']).to eq posts
        end
        include_examples 'renders template', :search
      end
    end
    context 'when there are no results' do
      include_examples 'renders 200 http status code'
      subject { get :search, keyword: '1VS5d1D3' }
      it 'returns empty search result' do
        subject
        expect(assigns['posts']).to eq []
      end
      include_examples 'renders template', :search
    end
  end
end
