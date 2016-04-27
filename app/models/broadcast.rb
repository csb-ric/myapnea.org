# frozen_string_literal: true

# A broadcast is a blog post. Blog posts can be edited by community managers and
# set to be published on specific dates.
class Broadcast < ActiveRecord::Base
  # Concerns
  include Deletable

  # Named Scopes
  scope :published, -> { current.where(published: true).where('publish_date <= ?', Time.zone.today) }

  # Model Validation
  validates :title, :slug, :description, :user_id, :publish_date, presence: true
  validates :slug, uniqueness: { scope: :deleted }
  validates :slug, format: { with: /\A(?!\Anew\Z)[a-z][a-z0-9\-]*\Z/ }

  # Model Relationships
  belongs_to :user
  belongs_to :category, class_name: 'Admin::Category'
  has_many :broadcast_comments

  # Model Methods

  def to_param
    slug.to_s
  end

  def url_hash
    {
      year: publish_date.year,
      month: publish_date.strftime('%m'),
      slug: slug
    }
  end
end
