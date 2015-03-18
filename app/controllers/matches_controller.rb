class MatchesController < ApplicationController
  before_action :logged_in_user, only: [:show]
  
  def create
    paras = match_params
    if paras[:type] == "Ai"
      p "holllla"
      mario = Ai.find(paras[:mario])
      luigi = Ai.find(paras[:luigi])
    elsif paras[:type] == "Human"
      mario = User.find(paras[:mario])
      luigi = User.find(paras[:luigi])
    elsif paras[:type] == "Mixed"
      mario = Ai.find(paras[:mario])
      luigi = User.find(paras[:luigi])
    end
    p [mario, luigi]
    @match = Match.new(mario: mario, luigi: luigi)
    if @match.save
      redirect_to @match
    else
      flash[:danger] = "Sorry something went wrong."
      redirect_to contact_path
    end
  end

  def show
    @match = Match.find(params[:id])    
    @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
    GameWorker.perform_async @match.id if @match.result == "open"
  end

  private

  def match_params
    params.require(:match).permit(:type, :mario, :luigi)
  end

  private
  
end
