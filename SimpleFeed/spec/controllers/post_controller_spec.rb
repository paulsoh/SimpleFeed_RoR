# require 'spec_helper'
require 'rails_helper'

describe PostsController do
  # ===============================================================
  #
  #                         SHARED EXAMPLES
  #
  # =============================================================== 

  shared_examples 'render status code' do |http_status_code|
    it "renders #{http_status_code} status code" do
      subject
      expect(response).to have_http_status(http_status_code)
    end
  end

  shared_examples 'renders template' do |name|
    it "renders #{name} template" do
      subject
      expect(response).to render_template(name)
    end
  end

  shared_examples 'single param update' do |params|
    let!(:post) { create(:post) }
    it "updates post #{params.keys[0]} field" do
      put :update, id: post.id, post: params
      expect(post.reload.send(params.keys[0]))
      .to eq params.values[0]
    end
  end

  # ===============================================================
  #
  #                              TEST
  #
  # ===============================================================

  describe '#index' do
    describe 'html format' do
      subject { get :index }

      include_examples 'render status code', 200
      include_examples 'renders template', :index

      context 'when more than one post' do
        let!(:post_list) { create_list :post, 3 }
        it 'returns an list of posts' do
          subject
          expect(assigns(:posts)).to eq(post_list)
        end
      end

      context 'when there is one post' do
        let!(:post) { create(:post) }
        it 'returns one post' do
          subject
          expect(assigns(:posts)).to eq([post])
        end
      end

      context 'when there are no posts' do
        it 'returns empty list(no post)' do
          subject
          expect(assigns(:posts)).to be_empty 
        end
      end
    end

    describe 'json format' do
      subject { get :index, format: :json }

      include_examples 'render status code', 200

      context 'when more than one post' do
        let!(:post_list) { create_list :post, 3 }
        it 'returns an list of posts' do
          subject
          expect(JSON.parse(response.body).length).to eq post_list.length
        end
      end

      context 'when there is one post' do
        let!(:post) { create(:post) }
        it 'returns one post' do
          subject
          expect(JSON.parse(response.body).length).to eq [post].length
        end
      end

      context 'when there are no posts' do
        it 'returns empty list(no post)' do
          subject
          expect(JSON.parse(response.body).length).to eq 0 
        end
      end
    end
  end

  describe '#show' do
    describe 'html format' do
      let!(:post) {create(:post)}
      context 'when param is valid and post exists' do
        subject { get :show, id: post.id }

        include_examples 'render status code', 200
        include_examples 'renders template', :show

        it 'returns post with post.id' do
          subject
          expect(assigns(:post).id).to eq post.id
        end
      end

      context 'when param is valid and post does not exist' do
        subject { get :show, id: Post.last.id + 1 }
        it 'redirect to :index view' do
          subject
          expect(response).to redirect_to posts_url
        end
      end

      context 'when param is invalid' do
        subject { get :show, id: -1 }

        it 'redirect to :index view' do
          subject
          expect(response).to redirect_to posts_url
        end
      end
    end

    describe 'json format' do
      let!(:post) {create(:post)}
      context 'when param is valid and post exists' do
        subject { get :show, id: post.id, format: :json }

        include_examples 'render status code', 200

        it 'returns post with post.id' do
          subject
          expect(JSON.parse(response.body)['id']).to eq post.id
        end
      end

      context 'when param is valid and post does not exist' do
        subject { get :show, id: Post.last.id + 1, format: :json }

        include_examples 'render status code', 404 

        it 'returns error message' do
          subject
          expect(JSON.parse(response.body)['error'])
          .to eq 'Post not found'
        end
      end

      context 'when param is invalid' do
        subject { get :show, id: -1, format: :json }

        include_examples 'render status code', 404 

        it 'returns error message' do
          subject
          expect(JSON.parse(response.body)['error'])
          .to eq 'Post not found'
        end
      end
    end
  end

  describe '#create' do
    describe 'html format' do
      context 'when post create success' do
        subject { post :create, post: attributes_for(:post) }

        it 'create new post' do
          expect { subject }
          .to change(Post, :count).by(1)
        end

        it 'redirect to new post' do
          subject
          expect(response).to redirect_to Post.last
        end
      end

      context 'when post create fails' do
        it 'does not create post with invalid title' do
          expect do
            post :create, post: { title: nil }
          end.to_not change(Post, :count)
        end

        it 'does not create post with invalid name' do
          expect do
            post :create, post: { name: nil }
          end.to_not change(Post, :count)
        end

        it 're-renders new method' do
          post :create, post: { title: nil, name: nil }
          expect(response).to render_template(:new)
        end
      end
    end

    describe 'json format' do
      context 'when post create success' do
        subject { post :create, post: attributes_for(:post), format: :json }

        it 'create new post' do
          expect { subject }
          .to change(Post, :count).by(1)
        end

        include_examples 'render status code', 201
      end

      context 'when post create fails' do
        it 'post with invalid title returns status 422' do
          post :create, post: { title: nil }, format: :json
          expect(response.status).to eq 422
        end

        it 'post with invalid name returns status 422' do
          post :create, post: { name: nil }, format: :json
          expect(response.status).to eq 422
        end
      end
    end
  end

  describe '#update' do
    describe 'html format' do
      context 'when post update success' do
        include_examples 'single param update', title: 'Update title'
        include_examples 'single param update', name: 'Update name'  
        include_examples 'single param update', content: 'Update content'

        let!(:post) { create(:post) }
        it 'redirects to updated post' do
          put :update, id: post.id
          expect(response).to redirect_to(:post)
        end
      end

      context 'when post update fail' do
        let!(:post) { create(:post) }

        it 'does not accept title less than 4 chars' do
          put :update, id: post.id, post: { title: 'abc' }
          expect(post.reload.title).to eq post.title
        end

        it 'does not accept nil name' do
          put :update, id: post.id, post: { name: nil }
          expect(post.reload.name).to eq post.name 
        end

        it 're-renders edit method' do
          put :update, id: post.id, post: { title: nil, name: nil }
          expect(response).to render_template(:edit)
        end
      end
    end
    describe 'json format' do
      context 'when post update success' do
        let!(:post) { create(:post) }

        it 'update post title' do
          put :update, id: post.id, post: { title: 'New title' }, format: :json
          expect(post.reload.title).to eq 'New title'
        end

        it 'update post name' do
          put :update, id: post.id, post: { name: 'New name' }, format: :json
          expect(post.reload.name).to eq 'New name'
        end

        it 'returns 204 status code' do
          put :update, id: post.id, format: :json
          expect(response.status).to eq 204
        end
      end

      context 'when post update fails due to invalid params' do
        let!(:post) { create(:post) }

        it 'does not accept title less than 4 chars' do
          put :update, id: post.id, post: { title: 'abc' }, format: :json
          expect(post.reload.title).to eq post.title
        end

        it 'does not accept nil name' do
          put :update, id: post.id, post: { name: nil }, format: :json
          expect(post.reload.name).to eq post.name 
        end

        it 'returns 422 status code' do
          put :update, 
              id: post.id, 
              post: { title: nil, name: nil }, 
              format: :json
          expect(response.status).to eq 422
        end
      end

      context 'when post update fails due to invalid id' do
        let!(:post) { create(:post) }
        subject do
          put :update, 
              id: Post.last.id + 1, 
              format: :json
        end

        include_examples 'render status code', 422

        it 'returns error message' do
          subject
          expect(JSON.parse(response.body)['error'])
          .to eq 'Post not found'
        end
      end
    end
  end

  describe '#delete' do
    describe 'html format' do
      let!(:post) {create(:post)}
      context 'when param is valid and post exists' do
        subject { delete :destroy, id: post.id }
        it 'deletes post from DB' do
          expect { subject }
          .to change(Post, :count).by(-1)
        end

        it 'redirects to :index' do
          subject
          expect(response).to redirect_to posts_url
        end
      end

      context 'when param is invalid' do
        subject { delete :destroy, id: Post.last.id + 1 }
        it 'invalid id redirects to index' do
          subject
          expect(response).to redirect_to posts_url
        end
      end
    end

    describe 'json format' do
      let!(:post) {create(:post)}
      context 'when param is valid and post exists' do
        subject { delete :destroy, id: post.id, format: :json }
        it 'deletes post from DB' do
          expect { subject }
          .to change(Post, :count).by(-1)
        end

        include_examples 'render status code', 204 
      end
      context 'when param is invalid' do
        subject { delete :destroy, id: Post.last.id + 1, format: :json }

        include_examples 'render status code', 422 

        it 'returns error message' do
          subject
          expect(JSON.parse(response.body)['error'])
          .to eq 'Post not found'
        end
      end
    end
  end
end
