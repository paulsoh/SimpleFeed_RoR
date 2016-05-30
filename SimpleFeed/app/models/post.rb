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

  def validate_post_title
    invalid_words = %w(광고 도박 무료 혜택 충전 성인) 
    words = []
    invalid_words.each { |word| words << word unless title.match(word).blank? }
    errors.add(:title, 
               "Invalid word in title: #{words.join(', ')}") unless words.blank?
  end
end
