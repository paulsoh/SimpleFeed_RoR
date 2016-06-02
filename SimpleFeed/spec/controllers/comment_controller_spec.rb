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

  shared_examples 'flashs error message on post view' do |msg|
    it 'flashs error message on post view' do
      subject
      expect(flash[:errors]).to include(msg)
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
        include_examples 'flashs error message on post view', "Commenter can't be blank"
      end
      context 'when body is not present' do
        subject do 
          post :create, 
               post_id: test_post.id, 
               comment: attributes_for(:comment, :no_body)
        end
        include_examples 'fails to create with invalid fields'
        include_examples 'flashs error message on post view', "Body can't be blank"
      end
      context 'when body is too short' do
        subject do 
          post :create, 
               post_id: test_post.id, 
               comment: attributes_for(:comment, :short_body)
        end
        include_examples 'fails to create with invalid fields'
        include_examples 'flashs error message on post view', "Body is too short (minimum is 5 characters)"
      end
      context 'when body is too long' do
        subject do 
          post :create, 
               post_id: test_post.id, 
               comment: attributes_for(:comment, :long_body)
        end
        include_examples 'fails to create with invalid fields'
        include_examples 'flashs error message on post view', "Body is too long (maximum is 140 characters)"
      end
      context 'when comment is identical to previous comment' do
        let!(:comment) {create(:comment, post: test_post)}
        subject do 
          post :create, 
               post_id: test_post.id, 
               comment: { commenter: comment.commenter,
                          body: comment.body }
        end
        include_examples 'flashs error message on post view', 'Commenter identical to last commenter'
        include_examples 'flashs error message on post view', 'Body identical to last body'
        include_examples 'fails to create with invalid fields'
      end
    end
    context 'with valid fields' do
      subject do 
        post :create, 
             post_id: test_post.id, 
             comment: attributes_for(:comment)
      end
      it 'stores comment in Comment' do
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

      it 'deletes comment from Comment' do 
        expect { subject }
        .to change(Comment, :count).by(-1)
      end

      it 'redirects to post show view' do
        subject
        expect(response).to redirect_to post
      end
      include_examples 'renders 302 http status code'
    end

    context 'when comment destroy fails' do
      subject { delete :destroy, post_id: post.id, id: comment.id } 
      before :each do
        allow_any_instance_of(Comment).to receive(:destroy).and_return(false)
      end
      it 'redirects to post show view' do 
        subject
        expect(response).to redirect_to post
      end
      include_examples 'flashs error message on post view', '댓글이 정상적으로 삭제되지 않았습니다'
    end
  end
end
