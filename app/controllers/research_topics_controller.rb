# frozen_string_literal: true

class ResearchTopicsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :set_research_topic, only: [:show, :edit, :update, :destroy]
  before_action :redirect_beginner, only: [:newest, :most_discussed, :index, :show, :new, :create, :my_research_topics]
  before_action :set_active_top_nav_link_to_research
  before_action :set_SEO_elements

  def intro
    redirect_to research_topics_path and return if !current_user
    render 'research_topics/intro/intro'
  end

  def first_topics
    redirect_to research_topics_path and return if !current_user
    redirect_to intro_research_topics_path and return if current_user.no_votes_user? and params[:read_intro].blank?
    redirect_to research_topics_path and return if current_user.experienced_voter?

    @research_topic = current_user.seeded_research_topic
    render 'research_topics/intro/first_topics'
  end

  def my_research_topics
    redirect_to research_topics_path and return if !current_user
    @research_topics = current_user.my_research_topics
    @new_research_topic = ResearchTopic.new
  end

  def index
    @research_topics = ResearchTopic.approved
    @new_research_topic = ResearchTopic.new
    respond_to do |format|
      format.html
      format.json
    end
  end

  def show
    @forum = Forum.for_research_topics
    @topic = @research_topic.topic
  end

  def edit
  end

  def new
    @research_topic = current_user.research_topics.new
  end

  def create
    @new_research_topic = current_user.research_topics.new(research_topic_params)

    if @new_research_topic.save
      @new_research_topic.create_associated_topic!
      flash[:notice] = 'Topic was successfully created.'
      redirect_to research_topic_path(@new_research_topic)
    else
      @research_topics = ResearchTopic.approved
      render :index
    end
  end

  def update
    flash[:notice] = 'Research topic was successfully updated.' if @research_topic.update(params.require(:research_topic).permit(:progress))
    @forum = Forum.find_by_slug(ENV['research_topic_forum_slug'])
    @topic = @research_topic.topic
    render :show
  end

  def destroy
    @research_topic.destroy
    @research_topic.topic.destroy
    respond_to do |format|
      format.html { redirect_to research_topics_path }
      format.json { head :no_content }
    end
  end

  # Voting
  def vote
    @research_topic = ResearchTopic.find(params[:research_topic_id])
    if current_user.experienced_voter? or @research_topic.seeded?
      if params["endorse_#{@research_topic.id}"].to_s == "1"
        @research_topic.endorse_by(current_user, params["comment_#{@research_topic.id}"])
      elsif params["endorse_#{@research_topic.id}"].to_s == "0"
        @research_topic.oppose_by(current_user, params["comment_#{@research_topic.id}"])
      else
        @vote_failed = true
        flash[:notice] = "Please either endorse or oppose this research topic." unless @research_topic.seeded?
      end

      if @research_topic.seeded?
        redirect_to first_topics_research_topics_path
      else
        redirect_to @research_topic
      end
    else
      head :ok
    end
  end

  def remote_vote
    @research_topic = ResearchTopic.find(params[:research_topic_id])
    if params["endorse_#{@research_topic.id}"].to_s == "1"
      @research_topic.endorse_by(current_user, params["comment_#{@research_topic.id}"])
    elsif params["endorse_#{@research_topic.id}"].to_s == "0"
      @research_topic.oppose_by(current_user, params["comment_#{@research_topic.id}"])
    else
      @vote_failed = true
    end

    respond_to do |format|
      format.js
    end
  end

  def change_vote
    research_topic = ResearchTopic.find(params[:research_topic_id])
    current_user.endorsed?(research_topic) ? research_topic.oppose_by(current_user) : research_topic.endorse_by(current_user)
    redirect_back(fallback_location: root_path)
  end

  private

  def redirect_beginner
    redirect_to intro_research_topics_path if current_user and current_user.no_votes_user?
    redirect_to first_topics_research_topics_path if current_user and current_user.novice_voter?
  end

  def set_research_topic
    @research_topic = ResearchTopic.find_by_slug(params[:id])
  end

  def research_topic_params
    params.require(:research_topic).permit(:text, :description)
  end

  def set_SEO_elements
    @title = @research_topic.present? ? @research_topic.topic.name : 'Help Create Future Research Topics Related to Sleep Apnea'
    @page_content = 'Vote on sleep apnea research and encourage sleep research to focus on patient outcomes! The next big sleep study could come from your interest in sleep apnea symptoms and treaments.'
  end
end
