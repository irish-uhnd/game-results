
require 'csv'
require 'json'
require 'pry'
#require 'pry-byebug'

games = JSON.parse(open('./data/games3.json', 'r').read)
# puts data
# coaches = data.map { |x| x['opp_coach'] }.sort.uniq

# games.each do |game|
#   puts coach.split[0..-2].join(' ')
# end

#coaches = JSON.parse(open('/Users/kyleflavin/Downloads/export_public_coaches_2021_08_29_09_09_20_057.json', 'r').read)
#teams = JSON.parse(open('/Users/kyleflavin/Downloads/export_public_teams_2021_08_28_17_17_36_509.json', 'r').read)
coaches = JSON.parse(open('./data/export_public_coaches_2021_09_22_22_03_39_017.json', 'r').read)
teams = JSON.parse(open('./data/export_public_teams_2021_09_22_18_25_06_387.json', 'r').read)

coach_names = coaches.map do |c|
  name = c['first_name']
  name += " #{c['middle_name']}" if c['middle_name']
  name += " #{c['last_name']}" if c['last_name']
  name += " #{c['suffix']}" if c['suffix']
  [name, c['id']]
end
coach_names = Hash[coach_names]

team_names = teams.map do |t|
  [t['name'], t['id']]
end
team_names = Hash[team_names]

csv_string = CSV.generate do |csv|
  games.each do |game|
    nd_coach = game['nd_coach']
    opp_coach = game['opp_coach']
    team = game['opponent'].strip
    nd_coach = coach_names[nd_coach] || game['nd_coach']
    opp_coach = coach_names[opp_coach] || game['opp_coach']
    team_id = team_names[team] || team

    #binding.pry if game['opp_coach'].include?("Bryant")

    # nd_rank = game['nd_rank'] == 'None' ? 667 : game['nd_rank']
    # nd_rank = game['nd_rank'] == 'None' ? 667 : game['nd_rank']

    csv << [
      game['date'],
      game['result'],
      game['site'],
      nd_coach,
      opp_coach,
      game['nd_score'],
      game['opp_score'],
      game['nd_rank'],
      game['opp_rank'],
      game['opp_final_rank'],
      team_id
    ]
  end
end

puts csv_string

#   {
#     "date": "1946-11-09",
#     "nd_rank": "2",
#     "result": "T",
#     "site": "YANKEE STADIUM",
#     "nd_coach": "Frank Leahy",
#     "nd_score": 0,
#     "opp_score": 0,
#     "opponent": "Army",
#     "opp_rank": "1",
#     "opp_final_rank": "2",
#     "opp_coach": "Earl Blaik"
#   },

# # csv_string = CSV.generate do |csv|
# #   csv << ['one', 'two', 'three']
# #   csv << ['four', 'five', 'size']
# #   csv << ['one', 'two', 'three']
# #   csv << ['one', 'two', 'three']
# #   csv << "one"
# # end

# puts csv_string
