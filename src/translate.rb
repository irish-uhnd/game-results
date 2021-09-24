# frozen_string_literal: true

# require './gamelist_full'
require 'json'

games = JSON.parse(open('data/games.json', 'r').read)
schools = open('translate_team_names', 'r').read.split("\n")
Hash[schools.collect { |s| c = s.split('|'); [c[0], c[1]] if c[1] }.compact]
school_map = Hash[schools.collect { |s| c = s.split('|'); [c[0], c[1]] if c[1] }.compact]
# puts school_map
# puts games

games.each do |game|
  opponent = game['opponent']
  opponent_capitalized = school_map[opponent]
  puts "Change #{opponent} to #{opponent_capitalized}"
  game['opponent'] = opponent_capitalized if opponent_capitalized
end

puts JSON.pretty_generate(games)
open('data/games2.json', 'w') do |f|
  f.write(JSON.pretty_generate(games))
end
