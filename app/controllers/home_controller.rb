class HomeController < ApplicationController

  before_action :authenticate_user!, except: [:dashboard, :landing]
  before_action :set_active_top_nav_link_to_home

  before_action :set_SEO_elements

  def dashboard
    if current_user
      flash.delete(:notice) if I18n.t('devise.sessions.signed_in') == flash[:notice]
      flash.delete(:alert)

      @surveys = current_user.visible_surveys.limit(3)
      @answer_sessions = current_user.answer_sessions.joins(:survey).where.not(surveys: { slug: nil }).order(:locked, "surveys.name_en", :encounter).limit(3)
      @posts = posts
    else
      render 'home/landing_v_7_3', layout: 'layouts/application-no-sidebar'
    end

  end

  def landing
    render 'home/landing_v_7_3', layout: 'layouts/application-no-sidebar'
  end

  def posts
    @posts = Post.current.not_research.visible_for_user.includes(:user, topic: :forum).order(created_at: :desc).page(params[:page]).per(10)
  end

  private

    def set_SEO_elements
      @page_title = 'Sleep Apnea Research and Community for Patient Outcomes'
      @page_content = 'Answer research surveys, submit and vote on new research questions, see the latest forum activity, and get involved in the sleep apnea community here at MyApnea.Org'
    end

end
