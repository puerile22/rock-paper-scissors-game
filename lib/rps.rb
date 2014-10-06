require_relative "./rps/entities/player.rb"
require_relative "./rps/entities/tourney.rb"
require_relative "./rps/entities/tours.rb"
require 'pry-byebug'
module RPS
end
def play(id)
  tie = RPS::Tourney.where(tour_id:id,:status=>['tie move','tie']).sort
  tour = RPS::Tour.find(id)
  if tie.length>0
    (0...tie.length.to_i/2).each do |i|
      if tie[i*2].status == 'tie move' && tie[i*2+1].status == 'tie move'
        player1 = {name:tie[i*2].player.name,move:tie[i*2].move}
        player2 = {name:tie[i*2+1].player.name,move:tie[i*2+1].move}
        result = RockPapeScis.play(player1,player2)
        if result == player1[:name] 
          tie[i*2].update(status:nil)
          winner = tie[i*2].player
          round = tie[i*2].round.to_i+1
          tie[i*2].update(round:round)
          tie[i*2+1].update(status:'lost')
          loser = tie[i*2+1].player
          wins = winner.wins.to_i+1
          losses = loser.losses.to_i+1
          winner.update(wins:wins)
          loser.update(losses:losses)
        elsif result == player2[:name]
          tie[i*2+1].update(status:nil)
          round = tie[i*2+1].round.to_i+1
          tie[i*2+1].update(round:round)
          tie[i*2].update(status:'lost')
          winner = tie[i*2+1].player
          loser = tie[i*2].player
          wins = winner.wins.to_i+1
          losses = loser.losses.to_i+1
          winner.update(wins:wins)
          loser.update(losses:losses)
        else
          tie[i*2+1].update(status:'tie')
          tie[i*2].update(status:'tie')
        end
      end
    end
  else
    tourney = RPS::Tourney.where(tour_id:id)
    if tourney.length == tour.rule.to_i
      (0..Math.log2(tour.rule.to_i).to_i).each do |j|
        tourneyss = RPS::Tourney.where(tour_id:id,:round=>[j+1..Math.log2(tour.rule.to_i).to_i])
        tourneys = RPS::Tourney.where(tour_id:id,round:j+1).sort
        if tourneyss.length == tour.rule.to_i/(2**j)
          (0...tourneys.length.to_i/2).each do |i|
            if tourneys[i*2].status == 'moved' && tourneys[i*2+1].status == 'moved' && tourneys[i*2+1].round == tourneys[i*2].round
              player1 = {name:tourneys[i*2].player.name,move:tourneys[i*2].move}
              player2 = {name:tourneys[i*2+1].player.name,move:tourneys[i*2+1].move}
              result = RockPapeScis.play(player1,player2)
              if result == player1[:name] 
                tourneys[i*2].update(status:nil)
                winner = tourneys[i*2].player
                round = tourneys[i*2].round.to_i+1
                tourneys[i*2].update(round:round)
                tourneys[i*2+1].update(status:'lost')
                loser = tourneys[i*2+1].player
                wins = winner.wins.to_i+1
                losses = loser.losses.to_i+1
                winner.update(wins:wins)
                loser.update(losses:losses)
              elsif result == player2[:name]
                tourneys[i*2+1].update(status:nil)
                round = tourneys[i*2+1].round.to_i+1
                tourneys[i*2+1].update(round:round)
                tourneys[i*2].update(status:'lost')
                winner = tourneys[i*2+1].player
                loser = tourneys[i*2].player
                wins = winner.wins.to_i+1
                losses = loser.losses.to_i+1
                winner.update(wins:wins)
                loser.update(losses:losses)
              else
                tourneys[i*2+1].update(status:'tie')
                tourneys[i*2].update(status:'tie')
              end
            end
          end
        end
      end
    end
  end
  round = RPS::Tourney.where(tour_id:id,status:'lost')
  if round.length == tour.rule.to_i-1
    winner = RPS::Tourney.where(tour_id:id,status:nil)
    player = winner[0].player
    tour.update(winner:player.name)
    winner[0].update(status:'won')
  end
end

def play_multi(id)
  tour = RPS::Tour.find(id)
  tourney = RPS::Tourney.where(tour_id:id)
  if tourney.length == tour.rule.to_i
    (0..Math.log2(tour.rule.to_i).to_i).each do |j|
      tourneyss = RPS::Tourney.where(tour_id:id,:round=>[j+1..Math.log2(tour.rule.to_i).to_i])
      tourneys = RPS::Tourney.where(tour_id:id,round:j+1).sort
      if tourneyss.length == tour.rule.to_i/(2**j)
        (0...tourneys.length.to_i/2).each do |i|
          if (tourneys[i*2].status == 'moved' && tourneys[i*2+1].status == 'moved') || (tourneys[i*2].status == 'tie move' && tourneys[i*2+1].status == 'tie move') && tourneys[i*2+1].round == tourneys[i*2].round
            player1 = {name:tourneys[i*2].player.name,move:tourneys[i*2].move}
            player2 = {name:tourneys[i*2+1].player.name,move:tourneys[i*2+1].move}
            result = RockPapeScis.play(player1,player2)
            binding.pry
            if result == player1[:name] 
              tourneys[i*2].update(status:nil)
              winner = tourneys[i*2].player
              wins = winner.wins.to_i+1
              loser = tourneys[i*2+1].player
              losses = loser.losses.to_i+1
              winner.update(wins:wins)
              loser.update(losses:losses)
              win = tourneys[i*2].wins.to_i+1
              tourneys[i*2].update(wins:win)
              if win == tour.game.to_i
                tourneys[i*2+1].update(status:'lost')
                round = tourneys[i*2].round.to_i+1
                tourneys[i*2].update(round:round)
              else
                tourneys[i*2+1].update(status:nil)
              end
            elsif result == player2[:name]
              tourneys[i*2+1].update(status:nil)
              winner = tourneys[i*2+1].player
              wins = winner.wins.to_i+1
              loser = tourneys[i*2].player
              losses = loser.losses.to_i+1
              winner.update(wins:wins)
              loser.update(losses:losses)
              win = tourneys[i*2+1].wins.to_i+1
              tourneys[i*2+1].update(wins:win)
              if win == tour.game.to_i
                tourneys[i*2].update(status:'lost')
                round = tourneys[i*2+1].round.to_i+1
                tourneys[i*2+1].update(round:round)
              else
                tourneys[i*2].update(status:nil)
              end
            else
              tourneys[i*2+1].update(status:'tie')
              tourneys[i*2].update(status:'tie')
            end
          end
        end
      end
    end
  end
  round = RPS::Tourney.where(tour_id:id,status:'lost')
  if round.length == tour.rule.to_i-1
    winner = RPS::Tourney.where(tour_id:id,status:nil)
    player = winner[0].player
    tour.update(winner:player.name)
    winner[0].update(status:'won')
  end
end