class UserMailer < ApplicationMailer

  def forum_digest(user)
    setup_email
    @user = user
    @email_to = user.email
    mail(to: @email_to, subject: "Forum Digest for #{Date.today.strftime('%a %d %b %Y')}")
  end

  def post_replied(post, user)
    setup_email
    @post = post
    @user = user
    @email_to = user.email
    mail(to: @email_to, subject: "New Forum Reply: #{@post.topic.name}")
  end

  def welcome(user)
    setup_email
    @user = user
    @email_to = user.email
    mail(to: @email_to, subject: "Welcome to MyApnea.Org!")
  end

  def welcome_provider(user)
    setup_email
    @user = user
    @email_to = user.email
    mail(to: @email_to, subject: "MyApnea.Org Provider Registration Information")
  end

  def mentioned_in_post(post, user)
    setup_email
    @user = user
    @post = post
    @email_to = user.email
    mail(to: @email_to,
      subject: "#{post.user.forum_name} Mentioned You on the MyApnea Forums")
  end

  def followup_survey(answer_session)
    setup_email
    @answer_session = answer_session
    @user = answer_session.user
    @email_to = answer_session.user.email
    mail(to: @email_to, subject: "Followup Survey Available on MyApnea.Org!")
  end

  def new_surveys_available(user)
    setup_email
    @user = user
    @email_to = user.email
    mail(to: @email_to, subject: "New Surveys Available on MyApnea.Org!")
  end

  def encounter_digest(owner, surveys_launched, survey_changes)
    setup_email
    @owner = owner
    @surveys_launched = surveys_launched
    @survey_changes = survey_changes
    @email_to = owner.email
    mail(to: @email_to, subject: "#{surveys_launched} Followup Survey#{'s' if surveys_launched != 1} Launched on #{Date.today.strftime('%a %d %b %Y')}")
  end

end
