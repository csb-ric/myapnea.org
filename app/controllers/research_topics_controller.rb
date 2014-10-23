class ResearchTopicsController < ApplicationController
  before_action :authenticate_user!

  before_action :no_layout, :only => [:research_topics, :vote_counter]
  before_action :set_research_topic, only: [:show, :update, :edit, :destroy]
  before_action :set_active_top_nav_link_to_research


  layout "community"

  authorize_actions_for ResearchTopic, only: [:index] #, :create, :new]

  def research_topics
    raise StandardError
  end


  def index
    @research_topics = ResearchTopic.accepted
  end

  def show
    authorize_action_for @research_topic
  end


  def create
    @research_topic = current_user.research_topics.new(research_topic_params)

    if @research_topic.save
      redirect_to research_topics_path, notice: "Your research question was successfully added."
    else
      render :new
    end
  end

  def update
    authorize_action_for @research_topic

    if current_user.can_moderate?(@research_topic)
      @research_topic.update(research_topic_moderator_params)
    end

    if @research_topic.update(research_topic_params)
      if current_user.can_moderate?(@research_topic)
        redirect_to admin_research_topic_path(@research_topic)
      else
        redirect_to research_topic_path(@research_topic)
      end
    else
      if current_user.can_moderate?(@research_topic)
        redirect_to admin_research_topics_path
      else
        render :edit
      end

    end
  end

  def edit
    authorize_action_for @research_topic

  end

  def new
    @research_topic = ResearchTopic.new
  end

  def destroy
    authorize_action_for @research_topic

    @research_topic.destroy

    if current_user.can?(:view_admin_dashboard)
      redirect_to admin_research_topics_path
    else
      redirect_to research_topics_path
    end

  end

  private

  def research_topic_params
    params.require(:research_topic).permit(:text, :description)
  end

  def research_topic_moderator_params
    params.require(:research_topic).permit(:state)
  end

  def set_research_topic
    @research_topic = ResearchTopic.find_by_id(params[:id])
  end

end