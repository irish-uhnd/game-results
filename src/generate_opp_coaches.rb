require 'json'
require 'csv'
require 'pry'

coach_data = open("./data/coaches.data", 'r').read.split("\n")
nd_coach_arr = CSV.parse(open("data/nd_coaches.csv", 'r').read).map {|coach| coach[0]}

opponent_coaches = []

coach_data.each do |coach|
  h = eval(coach)
  full_name = "#{h['first_name']} #{h['last_name']}"
  #puts full_name
  next if nd_coach_arr.include?(full_name)
  opponent_coaches.push({"first_name": h["first_name"], "middle_name": h["middle_name"], "last_name": h["last_name"]})
end


#puts "Size of coach_data: #{coach_data.size}"
#puts "Size of opponent_coaches: #{opponent_coaches.size}"
#puts "Size of nd_coach_arr: #{nd_coach_arr.size}"


out_data = CSV.generate do |csv|
  opponent_coaches.each do |coach|
    csv << [
      coach[:first_name],
      coach[:middle_name],
      coach[:last_name],
    ]
  end
end


puts out_data
