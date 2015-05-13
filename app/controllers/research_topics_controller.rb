class ResearchTopicsController < ApplicationController
  before_action :authenticate_user!

  before_action :no_layout,                           only: [ :research_topics ]
  before_action :set_active_top_nav_link_to_research

  authorize_actions_for ResearchTopic, only: [:index, :create]

  def intro
  end

  def first_topics
    redirect_to intro_research_topics_path if current_user.no_votes_user?
    @research_topic = current_user.highlighted_research_topic
  end

  def newest
    @rt_c1 = []
    @rt_c2 = []
    ResearchTopic.approved.each_with_index do |rt, index|
      (index+1)%2==0 ? (@rt_c2 << rt) : (@rt_c1 << rt)
    end
  end

  def most_discussed
    @research_topics = ResearchTopic.approved.most_discussed
  end

  def all
    @research_topics = ResearchTopic.approved
  end

  def index
    if current_user.experienced_voter?
      @research_topics = ResearchTopic.popular
    else
      redirect_to current_user.no_votes_user? ? intro_research_topics_path : first_topics_research_topics_path
    end
  end

  def create
    @new_research_topic = current_user.research_topics.new(research_topic_params)

    @new_research_topic.save

    render :index
  end

  def vote
    @research_topic = ResearchTopic.find(params[:research_topic_id])

    if current_user.experienced_voter? or @research_topic.seeded?
      params[:endorse] == 1 ? @research_topic.endorse_by(current_user) : @research_topic.oppose_by(current_user)
    else
      render nothing: true
    end

  end

  private

  def research_topic_params
    params.require(:research_topic).permit(:text, :description)

  end
end
