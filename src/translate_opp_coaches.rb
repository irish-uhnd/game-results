
require 'json'

games = JSON.parse(open('./data/games2.json', 'r').read)
lines = open('translate_coach_names', 'r').read
coach_map = Hash[lines.split("\n").map { |l| l.split('|') }]

games.each do |game|
  coach = game['opp_coach']
  words = coach.split.size

  if words > 2
    game['opp_coach'] = coach_map[coach]
  else
    game['opp_coach'] = coach.split.map(&:capitalize).join(' ')
  end

  puts "#{coach}" if coach.split.size < 3
end

open('./data/games3.json', 'w') do |f|
  f.write(JSON.pretty_generate(games))
end
