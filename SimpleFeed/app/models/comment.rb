class Comment < ActiveRecord::Base
  attr_accessible :body, :commenter, :post
  belongs_to :post

  validates :commenter, presence: true
  validates :body, presence: true, length: {minimum: 5, maximum: 140}

  validate :validate_non_duplicated_comment, on: :create

  private

  def validate_non_duplicated_comment
    errors.add(:commenter, 'identical to last commenter') if commenter == last_commenter 
    errors.add(:body, 'identical to last body') if body == last_body 
  end

  def last_commenter
    return if post.comments.blank?
    post.comments.last.commenter
  end

  def last_body
    return if post.comments.blank?
    post.comments.last.body
  end
end
