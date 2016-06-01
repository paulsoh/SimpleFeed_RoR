# encoding: utf-8
# require 'spec_helper'
require 'rails_helper'

describe CommentsController do
  # ===============================================================
  #
  #                         SHARED EXAMPLES
  #
  # =============================================================== 

  shared_examples 'fails to create with invalid fields' do
    it 'does not create post with invalid field' do
      expect{ subject }.to change(Comment, :count).by(0)
    end
  end
  
  # ===============================================================
  #
  #                         SHARED EXAMPLES
  #
  # =============================================================== 

  describe '#create' do
    let(:test_post) {create :post}
    context 'with invalid fields' do
      subject do 
        post :create, 
             post_id: test_post.id, 
             comment: attributes_for(:invalid_comment)
      end

      it 'redirect to post show view' do
        subject
        expect(response).to redirect_to test_post
      end
      include_examples 'renders 302 http status code'

      context 'when commenter is not present' do
        subject do 
          post :create, 
               post_id: test_post.id, 
               comment: attributes_for(:comment, :no_commenter)
        end
        include_examples 'fails to create with invalid fields'
      end
      context 'when body is not present' do
        subject do 
          post :create, 
               post_id: test_post.id, 
               comment: attributes_for(:comment, :no_body)
        end
        include_examples 'fails to create with invalid fields'
      end
      context 'when body is not too short' do
        subject do 
          post :create, 
               post_id: test_post.id, 
               comment: attributes_for(:comment, :short_body)
        end
        include_examples 'fails to create with invalid fields'
      end
      context 'when body is not too long' do
        subject do 
          post :create, 
               post_id: test_post.id, 
               comment: attributes_for(:comment, :long_body)
        end
        include_examples 'fails to create with invalid fields'
      end
      context 'when comment is identical to previous comment' do
        let!(:comment) {create(:comment, post: test_post)}
        subject do 
          post :create, 
               post_id: test_post.id, 
               comment: { commenter: comment.commenter,
                          body: comment.body }
        end
        it 'identical commenter twice raises error' do
          subject
          expect(assigns['comment'].errors.full_messages)
          .to include('Commenter identical to last commenter')
        end
        it 'identical body twice raises error' do
          subject
          expect(assigns['comment'].errors.full_messages)
          .to include('Body identical to last body')
        end
        include_examples 'fails to create with invalid fields'
      end
    end
    context 'with valid fields' do
      subject do 
        post :create, 
             post_id: test_post.id, 
             comment: attributes_for(:comment)
      end
      it 'comment is stored in post.comments' do
        expect { subject }
        .to change(Comment, :count).by(1)
      end
      it 'redirect to post show view' do
        post :create, post_id: test_post.id
        expect(response).to redirect_to test_post
      end
      include_examples 'renders 302 http status code'
    end
  end

  describe '#delete' do
    let!(:post) {create(:post)}
    let!(:comment) {create(:comment, post: post)}

    context 'when post id is invalid' do
      subject { delete :destroy, post_id: post.id, id: -1 } 

      it 'redirects to post show view' do
        subject
        expect(response).to redirect_to post
      end
      include_examples 'renders 302 http status code'
    end

    context 'when post id is valid' do
      subject { delete :destroy, post_id: post.id, id: comment.id } 

      it 'deletes comment from post.comments' do 
        expect { subject }
        .to change(Comment, :count).by(-1)
      end

      it 'redirects to post show view' do
        subject
        expect(response).to redirect_to post
      end
      include_examples 'renders 302 http status code'
    end
  end
end
