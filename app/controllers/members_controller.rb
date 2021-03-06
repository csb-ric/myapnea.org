# frozen_string_literal: true

# Displays public profiles for forum members.
class MembersController < ApplicationController
  before_action :find_member, only: [:photo, :profile_picture]
  before_action :find_member_or_redirect, only: [:show, :badges, :posts]

  def index
    redirect_to topics_path
  end

  # GET /members/:username
  def show
    redirect_to posts_member_path(params[:id])
  end

  # # GET /members/:username/badges
  # def badges
  # end

  # GET /members/:username/posts
  def posts
    @replies = @member.replies.order(created_at: :desc).page(params[:page]).per(10)
    @topics = @member.topics.order("replies_count desc").limit(3)
    @recent_topics = @member.topics.where.not(id: @topics.to_a.collect(&:id)).limit(3)
  end

  # GET /members/:username/profile_picture
  def profile_picture
    if @member&.photo.present?
      send_file_if_present @member&.photo
    else
      file_path = Rails.root.join("app", "assets", "images", "member-secret.png")
      File.open(file_path, "r") do |f|
        send_data f.read, type: "image/png", filename: "member.png"
      end
    end
  end

  private

  def find_member
    @member = User.current.find_by("LOWER(username) = ?", params[:id].to_s.downcase)
  end

  def find_member_or_redirect
    find_member
    empty_response_or_root_path(members_path) unless @member
  end
end
