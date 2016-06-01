# encoding: utf-8
# require 'spec_helper'
require 'rails_helper'

describe CommentsController do
  # ===============================================================
  #
  #                         SHARED EXAMPLES
  #
  # =============================================================== 

  shared_examples 'redirects to post#show' do
    it 'redirects to post show view' do
      subject
      expect(response).to redirect_to post
    end
  end

  describe '#create' do
  end

  describe '#delete' do
    let!(:post) {create(:post)}
    let!(:comment) {create(:comment, post: post)}

    context 'when post id is invalid' do
      subject { delete :destroy, post_id: post.id, id: -1 } 

      include_examples 'redirects to post#show'
      include_examples 'renders 302 http status code'
    end

    context 'when post id is valid' do
      subject { delete :destroy, post_id: post.id, id: comment.id } 

      it 'deletes comment from post.comments' do 
        expect { subject }
        .to change(Comment, :count).by(-1)
      end

      include_examples 'redirects to post#show'
      include_examples 'renders 302 http status code'
    end
  end
end
