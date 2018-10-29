# Point-class for point use:
class Point
  attr_accessor :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end
end

# Plane-class for plane use; for comparing planes (not points):
class Plane
  attr_accessor :p, :q, :z
  def initialize(p, q, z)
    @p = p
    @q = q
    @z = z
  end

  # uppend figure (x, y -> y, x):
  def upend
    self.q.x, self.q.y = self.q.y, self.q.x
    self.p.x, self.p.y = self.p.y, self.p.x

    return self
  end

  # print it:
  def to_s
    "(#{@p.x}, #{@p.y}); (#{@q.x}, #{@q.y}) -- #{@z}"
  end
end

# Aircraft-class
class Aircraft
  attr_accessor :width, :depth, :height, :shipments

  def initialize(width, depth, height)
    @width     = width
    @depth     = depth
    @height    = height
    @shipments = Array.new
  end

  # check of fits of a new shipment on aircraft:
  def fits_on_latitude_new?(plane)
    @width  >= plane.q.x &&
    @depth  >= plane.q.y &&
    @height >= plane.z
  end
  def fits_on_longitude_new?(plane)
    @width  >= plane.q.y &&
    @depth  >= plane.q.x &&
    @height >= plane.z
  end

  # check of fits of a new shipment on aircraft, if we already have a tower on
  # aircraft:
  def fits_on_latitude_tower?(plane)
    last_plane = @shipments.last.last

    last_plane.q.x - last_plane.p.x >= plane.q.x - plane.p.x &&
    last_plane.q.y - last_plane.p.y >= plane.q.y - plane.p.y &&
    last_plane.z + plane.z          <= @height
  end

  def fits_on_longitude_tower?(plane)
    last_plane = @shipments.last.last

    last_plane.q.x - last_plane.p.x >= plane.q.y - plane.p.y &&
    last_plane.q.y - last_plane.p.y >= plane.q.x - plane.p.x &&
    last_plane.z + plane.z          <= @height
  end

  # additional of shipment method:
  def add_shipment(plane)
    if @shipments.empty?
      if self.fits_on_latitude_new?(plane)
        @shipments << [plane]
      elsif self.fits_on_longitude_new?(plane)
        plane.upend
        @shipments << [plane]
      end
    else
      if self.fits_on_latitude_tower?(plane)
        plane.z += @shipments.last.last.z
        @shipments.last << plane
      elsif self.fits_on_longitude_tower?(plane)
        plane.z += @shipments.last.last.z
        plane.upend!
        @shipments.last << plane
      end
    end
  end

  # print it:
  def to_s
    self.shipments.each do |t|
      t.each{ |i| i }
    end
  end
end

air = Aircraft.new(10, 5, 1)
p1 = Point.new(0, 0)
p2 = Point.new(5, 10)
pl1 = Plane.new(p1, p2, 0.5)
air.add_shipment(pl1)

p1 = Point.new(0, 0)
p2 = Point.new(10, 5)
pl1 = Plane.new(p1, p2, 0.1)
air.add_shipment(pl1)

p1 = Point.new(0, 0)
p2 = Point.new(10,5)
pl1 = Plane.new(p1, p2, 0.1)
air.add_shipment(pl1)

p1 = Point.new(0, 0)
p2 = Point.new(0.5,0.5)
pl1 = Plane.new(p1, p2, 0.4)
air.add_shipment(pl1)

puts air.to_s
