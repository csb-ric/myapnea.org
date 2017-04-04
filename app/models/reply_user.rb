# frozen_string_literal: true

# Represents a user vote on a blog comment.
class ReplyUser < ApplicationRecord
  # Validations
  validates :reply_id, :user_id, :vote, presence: true
  # validates :chapter_id, :broadcast_id, presence: true

  # Relationships
  belongs_to :user
  belongs_to :broadcast
  belongs_to :chapter
  belongs_to :reply

  # Methods
  def up_vote!
    update vote: 1
  end

  def down_vote!
    update vote: -1
  end

  def remove_vote!
    update vote: 0
  end
end
