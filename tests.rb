# system("ruby aircraft_cargo.rb  -s tests/1/shipments_test.json  -a tests/1/aircrafts_test.json -o tests/1/#{"results_#{Time.now.to_s.delete(' ')}"}")
# system("ruby aircraft_cargo.rb  -s tests/2/shipments_test.json  -a tests/2/aircrafts_test.json -o tests/2/#{"results_#{Time.now.to_s.delete(' ')}"}")
# system("ruby aircraft_cargo.rb  -s tests/3/shipments_test.json  -a tests/3/aircrafts_test.json -o tests/3/#{"results_#{Time.now.to_s.delete(' ')}"}")
# system("ruby aircraft_cargo.rb  -s tests/4/shipments_test.json  -a tests/4/aircrafts_test.json -o tests/4/#{"results_#{Time.now.to_s.delete(' ')}"}")
# system("ruby aircraft_cargo.rb  -s tests/5/shipments_test.json  -a tests/5/aircrafts_test.json -o tests/5/#{"results_#{Time.now.to_s.delete(' ')}"}")
# system("ruby aircraft_cargo.rb  -s tests/6/shipments_test.json  -a tests/6/aircrafts_test.json -o tests/6/#{"results_#{Time.now.to_s.delete(' ')}"}")
# system("ruby aircraft_cargo.rb  -s tests/7/shipments_test.json  -a tests/7/aircrafts_test.json -o tests/7/#{"results_#{Time.now.to_s.delete(' ')}"}")
# system("ruby aircraft_cargo.rb  -s tests/8/shipments_test.json  -a tests/8/aircrafts_test.json -o tests/8/#{"results_#{Time.now.to_s.delete(' ')}"}")

require 'json'

shipments = []
aircrafts = []

for i in 0 ... 4000
    shipment_id     = "#{i}"
    shipment_width  = rand(1.0 .. 10.0).round(1)
    shipment_depth  = rand(1.0 .. 10.0).round(1)
    shipment_height = rand(1.0 .. 10.0).round(1)
    shipments << {"id": shipment_id, "width": shipment_width, "depth": shipment_depth, "height": shipment_height}

    if i < 100
      aircraft_id     = "#{i}"
      aircraft_width  = rand(10.0 .. 60.0).round(1)
      aircraft_depth  = rand(10.0 .. 60.0).round(1)
      aircraft_height = rand(10.0 .. 60.0).round(1)
      aircrafts << {"id": aircraft_id, "width": aircraft_width, "depth": aircraft_depth, "height": aircraft_height}
    end
end

system("mkdir ./tests/special")
File.open("./tests/special/shipments_test.json", "w") do |f|
  f.write shipments.to_json
end
File.open("./tests/special/aircrafts_test.json", "w") do |f|
  f.write aircrafts.to_json
end

system("ruby aircraft_cargo.rb  -s tests/special/shipments_test.json  -a tests/special/aircrafts_test.json -o tests/special/#{"results_#{Time.now.to_s.delete(' ')}"}")
