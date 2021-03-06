# frozen_string_literal: true

# Publicly available and published blog posts
class BlogController < ApplicationController
  before_action :find_broadcast_or_redirect, only: [:show, :cover]
  before_action :set_author, only: [:blog]
  before_action :set_category, only: [:blog]

  def blog
    broadcast_scope = Broadcast.current.published.order(publish_date: :desc, id: :desc)
    broadcast_scope = broadcast_scope.where(user: @author) if @author
    broadcast_scope = \
      if @category
        broadcast_scope.where(category: @category)
      else
        broadcast_scope.joins(:category).merge(Admin::Category.current.where(show_on_blog_roll: true))
      end
    @broadcasts = broadcast_scope.page(params[:page]).per(10)
    respond_to do |format|
      format.html
      format.atom
    end
  end

  def show
    @author = @broadcast.user
    @page = (params[:page].to_i > 1 ? params[:page].to_i : 1)
    @order = scrub_order(Reply, params[:order], "points desc")
    @order = params[:order] if ["points", "points desc"].include?(params[:order])
    reply_scope = \
      @broadcast.replies.points.includes(:broadcast)
                .where(reply_id: nil).reorder(@order)
                .page(@page).per(Reply::REPLIES_PER_PAGE)
    reply_scope = reply_scope.shadow_banned(current_user&.id) unless current_user && current_user.admin?
    @replies = reply_scope
    @broadcast.increment! :view_count
    render layout: "layouts/full_page"
  end

  # GET /blog/:slug/cover
  def cover
    send_file_if_present @broadcast.cover
  end

  private

  def find_broadcast_or_redirect
    @broadcast = Broadcast.current.published.find_by(slug: params[:slug])
    redirect_to blog_path unless @broadcast
  end

  def set_author
    return if params[:author].blank?
    @author = User.current.where("lower(username) = ?", params[:author].downcase).first
  end

  def set_category
    return if params[:category].blank?
    @category = Admin::Category.current.where("lower(slug) = ?", params[:category].downcase).first
  end
end
