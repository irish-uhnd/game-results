
require 'csv'
require 'json'

nd_coaches = open('nd_coaches.csv', 'r').read.split("\n")

csv_string = CSV.generate do |csv|
  nd_coaches.each do |coach|
    names = coach.split.size
    first_name = coach.split[0]
    middle_name = coach.split[1] if names > 2
    last_name = coach.split[-1]
    csv << [first_name, middle_name, last_name]
  end
end

puts csv_string
