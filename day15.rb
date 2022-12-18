# Day 15 of the advent of code 2022

class Sensor
    attr_accessor :cover

    def initialize(line)
        re = /^Sensor at x=(-?\d+), y=(-?\d+): .* at x=(-?\d+), y=(-?\d+)$/
        @x, @y, @xb, @yb = re.match(line).captures.map(&:to_i)
        @distance = (@x - @xb).abs + (@y - @yb).abs
    end

    def cover_y(y)
        dy = (@y - y).abs
        (@x - (@distance - dy))..(@x + (@distance - dy))
    end
end

def simplify_covers(array)
    return array if array.empty?

    # sort ranges by start
    array = array.sort_by { |r| r.begin }
    # get the earliest starting range
    first = array.shift
    second = first
    while second.begin <= first.end
        first = first.begin..[first.end, second.end].max
        return [first] if array.empty?

        second = array.shift
    end
    [first] + simplify_covers(array)
end

def get_covers(sensors, y)
    covers = sensors.map { |sensor| sensor.cover_y(y) }.reject { |range| range.size.zero? }
    simplify_covers(covers)
end

sensors = File.read('./inputs/day15.txt').split("\n").map { |line| Sensor.new(line) }

puts get_covers(sensors, 2_000_000).map { |r| r.size - 1 }.sum

# Part 2
4_000_000.times do |y|
    covers = get_covers(sensors, y)
    puts "#{covers.join(' ')}, #{y}" if covers.length > 1
end
