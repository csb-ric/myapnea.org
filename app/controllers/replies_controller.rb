# frozen_string_literal: true

# Allows users to reply to forum topics.
class RepliesController < ApplicationController
  before_action :authenticate_user!, except: [:vote, :show]
  before_action :find_parent_or_redirect, only: [:create]
  before_action :find_viewable_reply_or_redirect, only: [:show, :vote]
  before_action :find_editable_reply_or_redirect, only: [:edit, :update, :destroy]

  # # GET /replies
  # def index
  #   @replies = Reply.all
  # end

  # GET /replies/1
  def show
    respond_to do |format|
      format.html do
        if @reply.parent.is_a?(Broadcast)
          redirect_to blog_post_path(@reply.parent.url_hash.merge(page: @reply.page, anchor: @reply.anchor))
        elsif @reply.parent.is_a?(Chapter)
          redirect_to page_chapter_path(@reply.parent, page: @reply.page, anchor: @reply.anchor)
        else
          redirect_to root_path
        end
      end
      format.js
    end
  end

  def preview
    @reply = current_user.replies.new(reply_params)
  end

  def vote
    return unless current_user
    @reply_user = @reply.parent.reply_users.where(
      user_id: current_user.id, reply: @reply.id
    ).first_or_create
    case params[:vote]
    when 'up'
      @reply_user.up_vote!
    when 'down'
      @reply_user.down_vote!
    else
      @reply_user.remove_vote!
    end
  end

  # # GET /replies/new
  # def new
  #   @reply = Reply.new
  # end

  # # GET /replies/1/edit.js
  # def edit
  # end

  # POST /replies
  def create
    @reply = @parent.replies.where(user_id: current_user.id).new(reply_params)
    if @reply.save
      @reply.create_notifications!
      @reply.compute_shadow_ban!
      @reply.parent.touch(:last_reply_at) unless @reply.user.shadow_banned?
      current_user.read_parent!(@parent, @reply.id)
      render :create
    else
      render :new
    end
  end

  # PATCH /replies/1
  def update
    if @reply.update(reply_params)
      @reply.compute_shadow_ban!
      render :show
    else
      render :edit
    end
  end

  # DELETE /replies/1
  def destroy
    @reply.destroy
    render :show
  end

  private

  def find_parent_or_redirect
    @chapter = Chapter.current.find_by(slug: params[:chapter_id])
    @broadcast = Broadcast.current.published.find_by(slug: params[:broadcast_id])
    @parent = @chapter || @broadcast
    empty_response_or_root_path unless @parent
  end

  def find_viewable_reply_or_redirect
    @reply = Reply.current.find_by(id: params[:id])
    redirect_without_reply
  end

  def find_editable_reply_or_redirect
    @reply = current_user.editable_replies.find_by(id: params[:id])
    redirect_without_reply
  end

  def redirect_without_reply
    empty_response_or_root_path unless @reply
  end

  def reply_params
    params.require(:reply).permit(:description, :reply_id)
  end
end
