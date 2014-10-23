class ApplicationController < ActionController::Base

  def forem_user
    current_user
  end
  helper_method :forem_user

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception



  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || social_path
  end


  # Send 'em back where they came from with a slap on the wrist
  def authority_forbidden(error)
    Authority.logger.warn(error.message)
    redirect_to request.referrer.presence || root_path, :alert => "Sorry! You attempted to visit a page you do not have access to. If you believe this message to be unjustified, please contact us at <#{PPRN_SUPPORT_EMAIL}>."
  end



  def set_active_top_nav_link_to_research
    @active_top_nav_link = :research_topics
  end

  def set_active_top_nav_link_to_health_data
    @active_top_nav_link = :health_data
  end

  def set_active_top_nav_link_to_social
    @active_top_nav_link = :home
  end

  def set_active_top_nav_link_to_surveys
    @active_top_nav_link = :surveys
  end

  def set_active_top_nav_link_to_blog
    @active_top_nav_link = :blog
  end

  def no_layout
    render layout: false
  end

end
