require 'optparse'
require 'json'
require './planes.rb'

options = {}
OptionParser.new do |opt|
  opt.on('-s, --shipments FILE_PATH', 'File path to shipment params') { |o| options[:shipments_path] = o }
  opt.on('-a, --aircrafts FILE_PATH', 'File path to aircraft params') { |o| options[:aircrafts_path] = o }
  opt.on_tail("-h", "--help", 'Show this message') do
    puts opt
    exit
  end
end.parse!

opt = {}
opt[:shipments_path] = options.fetch(:shipments_path) do
 raise ArgumentError, "'shipments' parameter is not specified!"
end
opt[:aircrafts_path] = options.fetch(:aircrafts_path) do
 raise ArgumentError, "'aircrafts' parameter is not specified!"
end

# shipments reading to shipments-variable and:
shipments_file = File.read(options[:shipments_path])
shipments      = JSON.parse(shipments_file)
                     .sort_by { |hsh| hsh["depth"] }.reverse!

# aircrafts reading to aircraft-variable:
aircrafts_file = File.read(options[:aircrafts_path])
aircrafts      = JSON.parse(aircrafts_file)

# write results to file on results_DATETODAY/AIRCRAFT_ID.json:
# output_file = "results_#{Time.now.to_s.delete(' ')}"
output_file = "results"
system("mkdir #{output_file}")

for i in 0 ... aircrafts.size
  aircraft_object = Aircraft.new(aircrafts[i]["id"],
                                 aircrafts[i]["width"].to_i,
                                 aircrafts[i]["depth"].to_i,
                                 aircrafts[i]["height"].to_i)

  until aircraft_object.full? || shipments.empty?
    shipment        = shipments.shift
    shipment_object = Shipment.new(shipment["id"],
                                   shipment["width"].to_i,
                                   shipment["depth"].to_i,
                                   shipment["height"].to_i)
    aircraft_object.push(shipment_object)
  end

  File.open("./#{output_file}/#{aircrafts[i]["id"]}.json", "w") do |f|
    output = []
    aircraft_object.shipments.each{ |t| t.each do |o|
      output << o.to_h_of_c
    end }
    f.write output.to_json
  end

  # aircraft_object.puts_all
  aircraft_object.queue_shipments.each{ |j| shipments.unshift(j.to_h) }
end

# write to file on results_DATETODAY/lefts.json lefts shipments:
File.open("./#{output_file}/lefts.json", "w") do |f|
  f.write shipments.to_json
end
