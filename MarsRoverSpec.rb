require './MarsRover'
require "rspec/autorun"

describe MarsRover do
  it "has a starting location [0,0]" do
    rover = MarsRover.new
    expect(rover.getLocation).to eq([0,0])
  end

  it "has an initial direction" do
    rover = MarsRover.new
    expect(rover.getDirection).to eq(:N)
  end

  it "receives command f" do
    rover = MarsRover.new
    rover.sendCommand(:f, :f)
    expect(rover.getLocation).to eq([0,2])
    rover.sendCommand(:b, :b, :b)
    expect(rover.getLocation).to eq([0,-1])
  end

  it "raise invalid command error" do
    rover = MarsRover.new
    expect{rover.sendCommand(:a)}.to raise_error("invalid command(s)")
  end

  it "changes direction for command r/l" do
    rover = MarsRover.new(strtLocation:[0,0],dir: :N)
    rover.sendCommand(:r, :r, :r, :r, :r)
    expect(rover.getDirection).to eq(:E)
    rover.sendCommand(:l, :l)
    expect(rover.getDirection).to eq(:W)
  end

  it "f is always towards rovers direction" do
    rover = MarsRover.new(strtLocation:[0,0],dir: :E)
    rover.sendCommand(:f)
    expect(rover.getLocation).to eq([1, 0])
  end

  it "broadcasts coordinates and orientation" do
    rover = MarsRover.new(strtLocation:[0,0],dir: :N)
    rover.sendCommand(:l, :f, :r, :f, :l)
    expect(rover.broadcastPosition).to eq("X:-1, Y:1, Heading: W")
  end

  it "getNextLoc finds next location edge to edge " do
    rover = MarsRover.new(strtLocation:[5,0], dir: :E)
    location = rover.getNextLoc(:f)
    expect(location.x).to eq(-4)
  end

  describe Planet do
    it "raise error if circumference is >=0" do
      expect{Planet.new(circumference: 20)}.not_to raise_error
      expect{Planet.new(circumference:-20)}.to raise_error(/invalid/)
    end
  end

  it "wrapping from 1 edge to another at a given planet" do
    mars = Planet.new(circumference: 6)
    rover = MarsRover.new(strtLocation:[0,0], dir: :W, planet: mars)
    rover.sendCommand(:f, :f, :f, :f, :f, :f)
    expect(rover.getLocation).to eq([0, 0])
  end

  describe "#detectObstacle" do
    it "checks if next location has any obstacle" do
      mars = Planet.new(obstacles:[[0,1]])
      rover = MarsRover.new(planet:mars)
      nextLocation = Location.new(x:0, y:1)
      expect(rover.detectObstacle(nextLocation)).to eq(true)
    end
  end

  it "aborts sequence if obstacle detected" do
    mars = Planet.new(obstacles:[[0,1], [-2, 0]])
    rover = MarsRover.new(planet:mars)
    rover.sendCommand(:f, :f, :f)
    expect(rover.getLocation).to eq([0,0])
    rover.sendCommand(:l, :f, :f)
    expect(rover.broadcastPosition).to eq("X:-1, Y:0, Heading: W")
  end

  it "reports status after completed seq" do
    mars = Planet.new(obstacles:[[0,1], [-2, 0]])
    rover = MarsRover.new(planet:mars)
    expect(rover.sendCommand(:r, :f, :f)).to eq("all good")
    expect(rover.broadcastPosition).to eq("X:2, Y:0, Heading: E")
  end

  it "reports obstacle after aborted seq" do
    mars = Planet.new(obstacles:[[-3, 0]])
    rover = MarsRover.new(planet:mars)
    status = rover.sendCommand(:l, :f, :f, :f, :f, :f, :f)
    expect(status).to eq("Obstacle detected: X:-3, Y:0, Descreption: its a rock")
    expect(rover.broadcastPosition).to eq("X:-2, Y:0, Heading: W")
  end

  it "logs obstacles" do
    mars = Planet.new(obstacles:[[-3, 0], [-2, +2]])
    rover = MarsRover.new(planet:mars)
    rover.sendCommand(:l, :f, :f, :f)
    rover.sendCommand(:r, :f, :f, :f)
    listofObstacles = rover.getObstacles
    expect(listofObstacles.size).to eq(2)
    expect(rover.broadcastPosition).to eq("X:-2, Y:1, Heading: N")
  end

  it "logs route" do
    mars = Planet.new(circumference: 6)
    rover = MarsRover.new(planet:mars)
    rover.sendCommand(:l, :f, :f, :f, :f)
    route = rover.getLog
    expect(route.size).to eq(5)   #starting location is also in the log
    expect(route.last.coordinates).to eq([2,0])
  end
end
