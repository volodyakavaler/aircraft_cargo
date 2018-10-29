require 'optparse'
require 'json'

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
                     .group_by{ |i| i["height"].to_i }
                     .sort.each{ |i| i.flatten!.delete_at(0)}
                     .each{ |i| i.sort_by!{ |j| j["width"].to_i * j["depth"].to_i } }
                     .reverse

# aircrafts reading to aircraft-variable:
aircrafts_file = File.read(options[:aircrafts_path])
aircrafts      = JSON.parse(aircrafts_file)
