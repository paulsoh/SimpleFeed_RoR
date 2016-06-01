class CommentsController < ApplicationController
  before_filter -> { find_post(:id, :post_id) }, only: [:create, :destroy]
  before_filter :find_comment, only: [:destroy] 

  def create
    @comment = @post.comments.create(params[:comment])
    redirect_to post_path(@post)
  end

  def destroy
    @comment.destroy
    redirect_to post_path(@post)
  end

  private

  def find_comment
    @comment = @post.comments.find_by_id(params[:id])
    if @comment.blank?
      respond_to do |format|
        format.html { redirect_to @post }
      end
    end
  end
end
