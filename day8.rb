# Day 8 of the advent of code 2022

mat = File.read('./inputs/day8.txt').split("\n").map { |line| line.split('') }

class Tree
    attr_accessor :height, :south, :north, :east, :west, :south_score, :north_score, :east_score, :west_score

    def initialize(height)
        @height = height
        # highest tree in a direction, excluding self
        @south = -1
        @north = -1
        @west = -1
        @east = -1
        # scenic score in each direction
        @south_score = nil
        @north_score = nil
        @west_score = nil
        @east_score = nil
    end

    def sees_outside
        (@height > @south) or (@height > @north) or (@height > @west) or (@height > @east)
    end

    def look(tree, direction)
        case direction
        when 'north'
            @north = [tree.height, tree.north].max
        when 'south'
            @south = [tree.height, tree.south].max
        when 'west'
            @west = [tree.height, tree.west].max
        when 'east'
            @east = [tree.height, tree.east].max
        end
    end

    def scenic_score
        @south_score * @north_score * @east_score * @west_score
    end
end

class Forest
    attr_accessor :forest

    def initialize(mat)
        # initialize the forest
        @forest = mat.map { |line| line.map { |tree| Tree.new(tree.to_i) } }
    end

    def look_around
        # make each tree aware of the highest tree they see in each direction (going backwards)
        # Horizontal
        @forest.each do |line|
            line.each_cons(2) { |prev, cur| cur.look(prev, 'west') }
            line.reverse.each_cons(2) { |prev, cur| cur.look(prev, 'east') }
        end
        @forest.transpose.each do |line|
            line.each_cons(2) { |prev, cur| cur.look(prev, 'north') }
            line.reverse.each_cons(2) { |prev, cur| cur.look(prev, 'south') }
        end
    end

    def look_scenic
        # make each tree aware of the number of trees they see in each direction
        # Horizontal
        @forest.each do |line|
            # West
            # for each tree height h, distances[h] is the number of trees visible in the direction
            distances = Array.new(10, 0)
            line.each do |tree|
                tree.west_score = distances[tree.height]
                # after this tree:
                # - trees of lower height will only see this tree
                # - trees of greater height will see one more tree
                distances.map!.with_index { |e, i| i <= tree.height ? 1 : e + 1 }
            end
            # East
            distances = Array.new(10, 0)
            line.reverse.each do |tree|
                tree.east_score = distances[tree.height]
                distances.map!.with_index { |e, i| i <= tree.height ? 1 : e + 1 }
            end
        end
        # Vertical
        # North
        @forest.transpose.each do |line|
            distances = Array.new(10, 0)
            line.each do |tree|
                tree.north_score = distances[tree.height]
                distances.map!.with_index { |e, i| i <= tree.height ? 1 : e + 1 }
            end
            # South
            distances = Array.new(10, 0)
            line.reverse.each do |tree|
                tree.south_score = distances[tree.height]
                distances.map!.with_index { |e, i| i <= tree.height ? 1 : e + 1 }
            end
        end
    end

    def count_visible
        @forest.map { |line| line.map { |tree| tree.sees_outside ? 1 : 0 }.sum }.sum
    end

    def scenic_score
        @forest.map { |line| line.map(&:scenic_score).max }.max
    end
end

forest = Forest.new(mat)
forest.look_around
puts forest.count_visible
forest.look_scenic
puts forest.scenic_score

# I realize now that I could simplify this code by abstracting the directions ;
# can't be bothered to do it right now.
#
# Could also move the Tree things in Forest.look_scenic to a method in Tree
# which would be cleaner imo albeit longer
