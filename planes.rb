# Point-class for point use:
class Point
  attr_accessor :x, :y, :z

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end

  def to_s
    "(x: #{@x}, y: #{@y}, z: #{@z})"
  end
end

# Shipment-class:
class Shipment
  attr_accessor :p, :q, :height, :id

  # width -- Ox; depth -- Oy; height -- Oz
  def initialize(id, width, depth, height)
    @id     = id
    @p      = Point.new(0, 0, 0)
    @q      = Point.new(width, depth, 0)
    @height = height
  end

  def width
    @q.x - @p.x
  end

  def depth
    @q.y - @p.y
  end

  # upend shape of plane:
  def upend
    shipment = Shipment.new(self.id, self.width, self.depth, self.height)

    shipment.p.x, shipment.p.y = shipment.p.y, shipment.p.x
    shipment.q.x, shipment.q.y = shipment.q.y, shipment.q.x

    return shipment
  end
  def upend!
    self.p.x, self.p.y = self.p.y, self.p.x
    self.q.x, self.q.y = self.q.y, self.q.x

    return self
  end

  # recoordinate plane with under plane:
  def recoordinate_under(shipment)
    width  = self.width
    depth  = self.depth
    height = self.height

    self.p.x = shipment.p.x
    self.p.y = shipment.p.y
    self.p.z = shipment.p.z + height

    self.q.x = self.p.x + width
    self.q.y = self.p.y + depth
    self.q.z = shipment.p.z + height

    return self
  end

  # recoordinate plane with beside plane:
  def recoordinate_beside(shipment)
    width = self.width
    depth = self.depth

    self.p.x = shipment.q.x
    self.p.y = shipment.p.y

    self.q.x = shipment.q.x + width
    self.q.y = shipment.p.y + depth

    return self
  end

  # recoordinate plane with above plane:
  def recoordinate_above(shipment)
    width  = self.width
    depth  = self.depth

    self.p.x = shipment.p.x
    self.p.y = shipment.q.y

    self.q.x = self.p.x + width
    self.q.y = self.p.y + depth

    return self
  end

  def to_s
    "[#{@height}] #{@p} / #{@q}"
  end

  def to_h
    { "id": self.id, "width": self.width.to_s, "depth": self.depth.to_s, "height": self.height.to_s }
  end

  def to_h_of_c
    { "id": self.id,
      "x1": self.p.x.to_s, "y1": self.p.y.to_s, "z1": self.p.z.to_s,
      "x2": self.q.x.to_s, "y2": self.q.y.to_s, "z2": (self.q.z + self.height).to_s
    }
  end
end



# Aircraft-class:
class Aircraft
  attr_accessor :id, :width, :depth, :height, :shipments, :full, :queue_shipments

  def initialize(id, width, depth, height)
    @id              = id
    @width           = width
    @depth           = depth
    @height          = height
    @shipments       = Array.new
    @queue_shipments = Array.new
    @full            = false
  end

  def puts_all
    puts "AIR{#{@width}/#{@depth}/#{@height}}:"
    for t in 0 ... @shipments.size
        puts @shipments[t]
    end

    puts "QUE:"
    for t in 0 ... @queue_shipments.size
        puts @queue_shipments[t]
    end
  end

  # aircraft is full?
  def full?
    self.full
  end

  # fit shimpent on a shimpent?
  def is_under_fits?(shimpent)
    if @shipments.empty?
      self.width  >= shimpent.width &&
      self.depth  >= shimpent.depth &&
      self.height >= shimpent.height
    else
      under_shipment = @shipments.last.last

      under_shipment.width                                       >= shimpent.width  &&
      under_shipment.depth                                       >= shimpent.depth  &&
      self.height - (under_shipment.p.z + under_shipment.height) >= shimpent.height
    end
  end

  # fit shimpent on a shimpent with upend?
  def is_under_fits_with_upend?(shimpent)
    if @shipments.empty?
      shimpent = shimpent.upend

      self.width  >= shimpent.width &&
      self.depth  >= shimpent.depth &&
      self.height >= shimpent.height
    else
      under_shipment = @shipments.last.last
      shimpent       = shimpent.upend

      under_shipment.width                                       >= shimpent.width  &&
      under_shipment.depth                                       >= shimpent.depth  &&
      self.height - (under_shipment.p.z + under_shipment.height) >= shimpent.height
    end
  end

  # fit shimpent on beside a shimpent?
  def is_beside_fits?(shimpent)
    beside_shipment = @shipments.last.first

    self.width - beside_shipment.q.x >= shimpent.width &&
    self.depth - beside_shipment.p.y >= shimpent.depth &&
    self.height                      >= shimpent.height
  end

  # fit shimpent on beside a shimpent with upend?
  def is_beside_fits_with_upend?(shimpent)
    beside_shipment = @shipments.last.first
    shimpent        = shimpent.upend

    self.width - beside_shipment.q.x >= shimpent.width &&
    self.depth - beside_shipment.p.y >= shimpent.depth &&
    self.height                      >= shimpent.height
  end

  # fit shimpent on above a shimpent?
  def is_above_fits?(shimpent)
    beside_shipment = @shipments.last.first

    self.width                       >= shimpent.width &&
    self.depth - beside_shipment.q.y >= shimpent.depth &&
    self.height                      >= shimpent.height
  end

  # fit shimpent on above a shimpent with upend?
  def is_above_fits_with_upend?(shimpent)
    beside_shipment = @shipments.last.first
    shimpent        = shimpent.upend

    self.width                       >= shimpent.width &&
    self.depth - beside_shipment.q.y >= shimpent.depth &&
    self.height                      >= shimpent.height
  end

  # push a shipment on aircraft:
  def push(shipment)
    if @shipments.empty?
      if self.is_under_fits?(shipment)
        @shipments << [shipment]
      elsif self.is_under_fits_with_upend?(shipment)
        @shipments << [shipment.upend!]
      else
        @queue_shipments << shipment
      end
    else
      if self.is_under_fits?(shipment)
        @shipments.last << shipment.recoordinate_under(@shipments.last.last)
      elsif self.is_under_fits_with_upend?(shipment)
        @shipments.last << (shipment.upend!).recoordinate_under(@shipments.last.last)
      else
        if self.is_beside_fits?(shipment)
          @shipments << [shipment.recoordinate_beside(@shipments.last.first)]
        elsif self.is_beside_fits_with_upend?(shipment)
          @shipments << [(shipment.upend!).recoordinate_beside(@shipments.last.first)]
        else
          if self.is_above_fits?(shipment)
            @shipments << [shipment.recoordinate_above(@shipments.last.first)]
          elsif self.is_above_fits?(shipment)
            @shipments << [(shipment.upend!).recoordinate_above(@shipments.last.first)]
          else
            @queue_shipments << shipment
            self.full = true
          end
        end
      end
    end
  end
end

#
# air = Aircraft.new(10, 10, 1)
# s1 = Shipment.new(10, 4, 1)
# s2 = Shipment.new(10, 4, 1)
# s3 = Shipment.new(10, 4, 1)

# # s3 = Shipment.new(1, 10, 1)
# # s4 = Shipment.new(10, 1, 1)
# # s5 = Shipment.new(1, 10, 0.3)
# # s6 = Shipment.new(1, 10, 0.3)
# # s7 = Shipment.new(1, 10, 0.3)
# # s8 = Shipment.new(10, 1, 0.3)
# # s9 = Shipment.new(7, 10, 0.3)
#
#
# air.push(s1)
# air.push(s2)
# air.push(s3)
# puts air.full?
# # air.push(s4)
# # air.push(s5)
# # air.push(s6)
# # air.push(s7)
# # air.push(s8)
# # air.push(s9)
#
#
# air.puts_all
