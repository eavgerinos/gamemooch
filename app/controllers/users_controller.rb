class UsersController < ApplicationController

  before_action :authenticate_user!
  def games
    @user = User.find(params[:id])
    @games = @user.games.where(:mooch_user_id => nil).paginate(page: params[:page], per_page: 15)
  end

  def mooched_games
    @user = current_user
    @games = @user.mooched_games.where(:mooched => true).paginate(page: params[:page], per_page: 15)
    @submit_tag = "Unmooch"
    @action = games_unmooch_path
    @title = "Mooched"
    render "games_grid"
  end

  def pending_games
    @user = current_user
    @games = @user.mooched_games.where(:mooched => false).paginate(page: params[:page], per_page: 15)
    @submit_tag = "Cancel"
    @action = games_cancelmooch_path
    @title = "Pending for mooching"
    render "games_grid"
  end

  def moochedby_games
    @user = current_user
    @games = @user.games.where.not(:mooch_user_id => nil).where(:mooched => true).order("created_at").reverse_order.paginate(page: params[:page], per_page: 15)
    @submit_tag = "Unmooch Games"
    @action = games_unmooch_path
    @title = "Mooched by others"
    render "games_grid"
  end

  def requested_games
    if request.post?
      response = params[:selectImage]
      if response
        response.each do |game|
          game = json(game)
          id = game['id']
          @game = Game.find(id)
          if params[:commit] == "Decline"
            @game.mooch_user = nil
          else
            @game.mooched = true
            UserMailer.send_approval(@game.mooch_user, @game.title).deliver
          end
          @game.save
        end
        redirect_to request.env["HTTP_REFERER"]
      else
        flash[:error] = "Please select a game"
        redirect_to request.env["HTTP_REFERER"]
      end
    else
      @user = current_user
      @games = @user.games.where.not(:mooch_user_id => nil).where(:mooched => false).order("created_at").reverse_order.paginate(page: params[:page], per_page: 15)
    end
  end

  def delete_games
    response = params[:selectImage]
    @games = []
    if response
      response.each do |game|
        game = json(game)
        id = game['id']
        @game = Game.find(id)
        @game.destroy
        @games.append(@game.title)
      end
      flash[:error] = "#{@games.to_sentence} Deleted"
      redirect_to request.env["HTTP_REFERER"]
    else
      flash[:error] = "Please select a game"
      redirect_to request.env["HTTP_REFERER"]
    end
  end

  def index
    @users = User.all
  end

end
