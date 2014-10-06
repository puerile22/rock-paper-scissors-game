require_relative '../config/environments.rb'
require 'sinatra'
require 'rubygems'
require 'pry-byebug'

class RPS::Server < Sinatra::Application
  configure do 
    set :bind, '0.0.0.0'
    enable :sessions
  end

  def check
    if !session[:user_id]
      redirect to ('/')
    end
  end

  get '/' do
    @players = RPS::Player.all
    @players = @players.sort_by{|a| a.wins}.reverse
    if !session[:user_id].nil?
      @name = RPS::Player.find(session[:user_id].to_i).name
      redirect to ("/gamelobby?name=#{@name}")
    end
    erb :home
  end

  post '/login' do
    @name = params[:name]
    @player = RPS::Player.find_by(name:params[:name])
    @password = params[:password]
    if @player == nil
      redirect to ('/login')
    end
    if @player.password_hash == Digest::SHA2.hexdigest(@password)
      session[:user_id] = @player.id
      redirect to ("/gamelobby?name=#{@name}")
    else
      redirect to ('/password')
    end
  end

  get '/login' do
    erb :login
  end

  get '/password' do
    erb :password
  end

  get '/gamelobby' do
    check
    @player = RPS::Player.find_by(name:params[:name])
    @wins = RPS::Tour.where(winner:@player.name)
    @tourneys = RPS::Tourney.where(player_id:@player.id,:status=>[nil,'tie'])
    @tourney = RPS::Tourney.where(player_id:@player.id)
    @tours = []
    @tourney.each do |i|
      @tours<<i.tour_id
    end
    @other_tourneys = RPS::Tourney.all.where.not(player_id:@player.id).to_a
    @join_tourneys = []
    @available = @other_tourneys.uniq{|b| b.tour_id}
    @available.each do |i|
      @tour = RPS::Tourney.where(tour_id:i.tour_id)
      @join_tourneys << i if !@tours.include?(i.tour_id) && (i.tour.winner == nil && @tour.length < i.tour.rule.to_i)
    end
    erb :gamelobby
  end

  # get '/signup' do
  #   @name = params[:name]
  #   erb :signup
  # end

  post '/signup' do
    @name = params[:name]
    @password = Digest::SHA2.hexdigest(params[:password])
    player = RPS::Player.new(name:@name,wins:0,losses:0,password_hash:@password)
    if player.valid?
      player.save
      session[:user_id] = player.id
      redirect to ("/gamelobby?name=#{@name}")
    else
      redirect to('/')
    end
  end 

  get '/tours/:id/:name' do
    check
    @name = params[:name]
    @player = RPS::Player.find_by(name:@name)
    @id = params[:id].to_i
    if RPS::Tourney.find_by(tour_id:@id,player_id:@player.id) == nil
      RPS::Tourney.create(player_id:@player.id,tour_id:@id,round:1,wins:0)
    end
    @rule = RPS::Tour.find_by(id:@id).rule.to_i
    @info = []
    @arr = [*1..Math.log2(@rule)+1]
    @arr.each_with_index do |i,j|
      @info << RPS::Tourney.where(tour_id:@id,:round=>@arr[j..-1]).sort
    end
    erb :play
  end

  get '/view/:id/:name' do
    check
    @name = params[:name]
    @player = RPS::Player.find_by(name:@name)
    @id = params[:id].to_i
    if RPS::Tourney.find_by(tour_id:@id,player_id:@player.id) == nil
      RPS::Tourney.create(player_id:@player.id,tour_id:@id,round:1,wins:0)
    end
    @rule = RPS::Tour.find_by(id:@id).rule.to_i
    @info = []
    @arr = [*1..Math.log2(@rule)+1]
    @arr.each_with_index do |i,j|
      @info << RPS::Tourney.where(tour_id:@id,:round=>@arr[j..-1]).sort
    end
    erb :view
  end

  get '/submit' do
    check
    @name = params[:name]
    @player = RPS::Player.find_by(name:@name)
    @id = params[:id].to_i
    @move = params[:move]
    @new_move = RPS::Tourney.find_by(player_id:@player.id,tour_id:@id)
    @new_move.move = @move 
    if @new_move.status == nil
      @new_move.status = 'moved'
    elsif @new_move.status == 'tie'
      @new_move.status = 'tie move'
    end
    @new_move.save
    if RPS::Tour.find(@id).game == 1
      play(@id)
    else
      play_multi(@id)
    end
    erb :submit
  end

  post '/newgame' do
    check
    @name = params[:name]
    @tour_name = params[:tourname]
    @rule = params[:rule].to_i
    @game = params[:game][0].to_i
    @player_id = params[:player_id]
    if @rule&(@rule-1) == 0 
      @newtour = RPS::Tour.create(name:@tour_name,rule:@rule,game:@game)
      RPS::Tourney.create(player_id:@player_id,tour_id:@newtour.id,round:1,wins:0)
    end
    redirect to("/gamelobby?name=#{@name}")
  end

  delete '/logout' do
    session[:user_id] = nil
    redirect to ('/')
  end

  run! if app_file == $0
end