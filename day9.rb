# Day 9 of the advent of code 2022

require 'set'

commands = File.read('./inputs/day9.txt').split("\n").map { |line| line.split(' ') }

class Knot
    attr_accessor :visited, :ti, :tj

    def initialize
        # Current head position
        @hi = 0
        @hj = 0
        # Current tail position
        @ti = 0
        @tj = 0
        # positions visited by the tail, in order (non-unique)
        @visited = [[0, 0]]
    end

    def move(direction)
        case direction
        when 'R'
            @hi += 1
        when 'L'
            @hi -= 1
        when 'U'
            @hj += 1
        when 'D'
            @hj -= 1
        end
        follow
        @visited.push [@ti, @tj]
    end

    def goto(i, j)
        @hi = i
        @hj = j
        follow
        @visited.push [@ti, @tj]
    end

    def follow
        # have the tail follow the head
        return if is_touching

        if (@hi - @ti).abs > 1
            # follow in the direction where separation occured
            @ti = @hi + (@ti <=> @hi)
            @tj = if (@hj - @tj).abs > 1
                      # this means the head moved in a diagonal
                      @hj + (@tj <=> @hj)
                  else
                      # the head moved straight: in the orthogonal direction, we end up at the same level
                      @hj
                  end
        elsif (@hj - @tj).abs > 1
            @tj = @hj + (@tj <=> @hj)
            if (@hi - @ti).abs > 1
                @hi + (@ti <=> @hi)
            else
                @ti = @hi
            end
        end
    end

    def is_touching
        ((@hi - @ti).abs <= 1) and ((@hj - @tj).abs <= 1)
    end

    def to_s
        "h: (#{@hi},#{@hj}), t: (#{@ti},#{@tj})"
    end
end

knot = Knot.new

commands.each { |(direction, n)| n.to_i.times { knot.move(direction) } }

puts knot.visited.to_set.length

class Rope
    attr_accessor :knots

    def initialize(n)
        @knots = Array.new(n - 1) { Knot.new }
        @n = n
    end

    def move(direction)
        # puts "Move in #{direction} direction"
        @knots[0].move(direction)
        @knots.each_cons(2) do |head, follower|
            # puts head.to_s + ' ' + follower.to_s
            follower.goto(head.ti, head.tj)
        end
    end
end

rope = Rope.new(10)

commands.each { |(direction, n)| n.to_i.times { rope.move(direction) } }

puts rope.knots[-1].visited.to_set.length
