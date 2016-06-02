# encoding: utf-8
class CommentsController < ApplicationController
  before_filter -> { find_post(:id, :post_id) }, only: [:create, :destroy]
  before_filter :find_comment, only: [:destroy] 

  def create
    @comment = @post.comments.build(params[:comment])
    if @comment.save
      redirect_to post_path(@post)
    else
      redirect_to post_path(@post), 
                  flash: { errors: @comment.errors.full_messages }
    end
  end

  def destroy
    if @comment.destroy
      redirect_to post_path(@post)
    else
      redirect_to post_path(@post),
                  flash: { errors: ['댓글이 정상적으로 삭제되지 않았습니다'] }
    end
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
