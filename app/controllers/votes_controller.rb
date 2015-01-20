class VotesController < ApplicationController
  before_filter :authenticate_user!

  def vote
    if params[:vote][:research_topic_id] and current_user.can_vote_for?(ResearchTopic.find(params[:vote][:research_topic_id])) and current_user.has_votes_remaining?(params[:vote][:rating].to_i)

      @vote = Vote.find_or_initialize_by(user_id: current_user.id, research_topic_id: params[:vote][:research_topic_id])
      @vote.rating = params[:vote]["rating"]
      saved = @vote.save
    elsif params[:vote][:question_id]
      @vote = Vote.find_or_initialize_by(user_id: current_user.id, question_id: params[:vote][:question_id])
      @vote.rating = params[:vote]["rating"]
      saved = @vote.save
    end

    if @vote
      respond_to do |format|
        format.js
        format.json { render json: { saved: saved } }
      end
    else
      respond_to do |format|
        format.js { render nothing: true }
        format.json { head :no_content }
      end
    end

  end



  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def object_params
    params.require(:vote).permit(:rating)
  end
end
