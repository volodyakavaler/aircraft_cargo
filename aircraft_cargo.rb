################################################################################
#                            BIN PACKING PROBLEM                               #
# To run the program you should input:                                         #
#   aircraft_cargo.rb -s shipments-file -a aircrafts-file                      #
# shipments-file and aircrafts-file is json-file, where you describe shipments #
# and aircrafts:                                                               #
#   [                                                                          #
#   {"id": "1", "width": "10", "depth": "10", "height": "10"}                  #
#   ]                                                                          #
#   this params is example only.                                               #
# This problem is solved by the simplest method: shipments are sorted by       #
# depth and put on the first appropriate by height then by level of shipment-  #
# depth.                                                                       #
# After completing the program, you receive: several files with distributed    #
# shipments, undistributed shipments, tex-file with "picture" of this and      #
# pdf-file with this pictures.                                                 #
################################################################################

require 'optparse'
require 'json'
require './planes.rb'
require './drawer.rb'

# options for terminal-execute:
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
output_path = "results_#{Time.now.to_s.delete(' ')}"
system("mkdir #{output_path}")

# .tex-file initialize:
File.open("./#{output_path}/picture.tex", "a"){ |g| g.write tex_preambule_begin}

# main-calculations:
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

  # write to files necessary information:
  File.open("./#{output_path}/#{aircrafts[i]["id"]}.json", "w") do |f|
    File.open("./#{output_path}/picture.tex", "a") do |g|
      g.write tikz_begin(aircraft_object)
      output = []
      aircraft_object.shipments.each{ |t| t.each do |o|
        g.write  draw_shipment(o)
        output << o.to_h_of_c
      end }
      f.write output.to_json
      g.write tikz_end(aircraft_object.id)
    end
  end

  aircraft_object.queue_shipments.each{ |j| shipments.unshift(j.to_h) }
end

# finally-work with .tex-files (.pdf with .tex-file you can see in
# results_DATETODAY directory):
File.open("./#{output_path}/picture.tex", "a"){ |g| g.write tex_preambule_end}
system ("pdflatex ./#{output_path}/picture.tex")
system ("mv picture.pdf ./#{output_path}")
system ("rm picture.log")
system ("rm picture.aux")

# write to file on results_DATETODAY/lefts.json lefts shipments:
File.open("./#{output_path}/lefts.json", "w") do |f|
  f.write shipments.to_json
end
