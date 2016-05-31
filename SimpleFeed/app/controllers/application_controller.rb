class ApplicationController < ActionController::Base
  protect_from_forgery

  def find_post(attr, key = attr)
    @post = Post.send("find_by_#{attr}", params[key])

    if @post.blank?
      respond_to do |format|
        format.html { redirect_to posts_url }
        format.json do 
          render json: { error: 'Post not found' }, status: :not_found
        end
      end
    end
  end
end
