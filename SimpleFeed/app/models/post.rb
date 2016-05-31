# encoding: utf-8
# The Model: Post
class Post < ActiveRecord::Base
  attr_accessible :content, :name, :url, :title, :tags_attributes

  validates :name, presence: true
  validates :title, presence: true,
                    length: { minimum: 5 }

  has_many :comments, dependent: :destroy
  has_many :tags

  accepts_nested_attributes_for :tags, 
                                allow_destroy: :true, 
                                reject_if: proc { |attrs| attrs.all? {|_k, v| v.blank? } }

  validate :validate_post_title
#  validate :validate_non_duplicated_post

  private

  def validate_post_title
    return if title.blank?
    invalid_words = %w(광고 도박 무료 혜택 충전 성인) 
    words = []
    invalid_words.each { |word| words << word unless title.match(word).blank? }
    errors.add(:title, 
               "Invalid word in title: #{words.join(', ')}") unless words.blank?
  end

  def validate_non_duplicated_post
    if title == last_post_title
      errors.add(:title, 
                 'Identical title to last post')
    elsif name == last_post_name 
      errors.add(:name, 
                 'Identical name to last post')
    end
  end

  def last_post_name
    Post.last.name
  end

  def last_post_title
    Post.last.title
  end
end
