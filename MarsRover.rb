
class Location
  attr_accessor :x, :y, :info
  def initialize(x:, y:, info: nil)
    @x = x
    @y = y
    @info = info
  end

  def coordinates
    [@x, @y]
  end
end

#insted of using a 2D projection of a sphere
#a simple grid will represent the planet of the surface
class Planet
  attr_reader :circumference, :obstacles
  def initialize(circumference: 10, obstacles: [])
    raise "invalid planet circumference" unless circumference >= 0
    @circumference = circumference
    @obstacles = obstacles
  end
end

class MarsRover
    def initialize(strtLocation:[0,0], dir: :N, planet: Planet.new)
      @location = Location.new(x: strtLocation[0], y: strtLocation[1])
      @compass = [:N, :E, :S, :W]
      @direction = dir
      @foundObstacles = []
      @log = [@location]

      @exploredPlanet = planet
      @upperLimit = planet.circumference/2
      @lowerLimit = -planet.circumference/2
    end

    def getLocation
      @location.coordinates
    end

    def getDirection
      @direction
    end

    def getObstacles
      @foundObstacles
    end

    def getLog
      @log
    end

    def broadcastPosition
      "X:#{@location.x}, Y:#{@location.y}, Heading: #{@direction.to_s}"
    end

    def broadcastsObstacle(location)
      "Obstacle detected: X:#{location.x}, Y:#{location.y}, Descreption: #{location.info}"
    end

    def sendCommand(*commands)
      status = "all good"
      commands.each do |command|
        raise "invalid command(s)" unless [:l, :r, :f, :b].include?(command)

        (self.turnRover(command); next) if command == :l or command == :r
        nextSq = self.getNextLoc(command)
        if detectObstacle(nextSq)
          nextSq.info = "its a rock"
          status = self.broadcastsObstacle(nextSq)
          @foundObstacles << nextSq
          break
        else
          nextSq.info = "clear"
          @location = nextSq
          @log << nextSq
        end
      end
      return status
    end

    def getNextLoc(command)
      x = @location.x
      y = @location.y
      if (@direction == :N and command == :f) or (@direction == :S and command == :b)
        y = y + 1 > @upperLimit ? @lowerLimit + 1 : y + 1
      elsif (@direction == :N and command == :b) or (@direction == :S and command == :f)
        y = y - 1 < @lowerLimit ? @upperLimit - 1 : y - 1
      elsif (@direction == :E and command == :f) or (@direction == :W and command == :b)
        x = x + 1 > @upperLimit ? @lowerLimit + 1 : x + 1
      elsif (@direction == :E and command == :b) or (@direction == :W and command == :f)
        x = x - 1 < @lowerLimit ? @upperLimit - 1 : x - 1
      end
      return Location.new(x:x, y:y)
    end

    def turnRover(dir)
      @direction = @compass.index(@direction) + 1 > 3 ? @compass[0] : @compass[@compass.index(@direction) + 1] if dir == :r
      @direction = @compass[@compass.index(@direction) -1] if dir == :l
    end

    def detectObstacle(location)
      @exploredPlanet.obstacles.include?(location.coordinates)
    end
end
