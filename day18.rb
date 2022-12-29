# Day 18 of the advent of code 2022

class Drop
    attr_accessor :touching_sides, :cubes

    def initialize(path)
        @cubes = File.read(path).split("\n").map { |line| line.split(',').map { |s| s.to_i + 2 } }
        @xmax = @cubes.map { |x, _, _| x }.max + 4
        @ymax = @cubes.map { |_, y, _| y }.max + 4
        @zmax = @cubes.map { |_, _, z| z }.max + 4
        @space = Array.new(@xmax) do
            Array.new(@ymax) do
                Array.new(@zmax) { false }
            end
        end
        @cubes.each { |x, y, z| @space[x][y][z] = true }
        @touching_sides = @cubes.map { |x, y, z| count_touching(x, y, z) }
        # part2
        explore_outside
    end

    def count_touching(x, y, z)
        neighbors(x, y, z).map { |xn, yn, zn| @space[xn][yn][zn] ? 1 : 0 }.sum
    end

    def neighbors(x, y, z)
        [[x - 1, y, z], [x + 1, y, z], [x, y - 1, z], [x, y + 1, z], [x, y, z - 1],
         [x, y, z + 1]]
    end

    def explore_outside
        # create the matrix which encodes if a block is outside
        @outside = Array.new(@xmax) do
            Array.new(@ymax) do
                Array.new(@zmax) { false }
            end
        end
        # tell the edges that they are outside (quite verbose)
        @outside[0] = Array.new(@ymax) { Array.new(@zmax, true) }
        @outside[-1] = Array.new(@ymax) { Array.new(@zmax, true) }
        @xmax.times do |x|
            @outside[x][0] = Array.new(@zmax + 2, true)
            @outside[x][-1] = Array.new(@zmax + 2, true)
            @ymax.times do |y|
                @outside[x][y][0] = true
                @outside[x][y][-1] = true
            end
        end
        # now we explore all cubes and propagate the outside property to neighbors
        # do multiple sweeps until a sweep didn't change anything
        changed = true
        changed = sweep_outside while changed
    end

    def sweep_outside
        changed = false
        # sweep
        @outside.each_with_index do |xarray, x|
            xarray.each_with_index do |yarray, y|
                yarray.each_with_index do |zvalue, z|
                    # if we are on a block that is already known to be outside or on lava, we skip
                    next if zvalue or @space[x][y][z]

                    # if one of the neighboring blocks is outside, we are also outside
                    if neighbors(x, y, z).any? { |xn, yn, zn| @outside[xn][yn][zn] }
                        @outside[x][y][z] = true
                        changed = true
                    end
                end
            end
        end
        # return whether the sweep changed anything
        changed
    end

    def count_facing_outside
        faces_per_cube = cubes.map do |x, y, z|
            neighbors(x, y, z).map { |xn, yn, zn| @outside[xn][yn][zn] ? 1 : 0 }.sum
        end
        faces_per_cube.sum
    end
end

drop = Drop.new('./inputs/day18.test.txt')
# part 1
puts drop.touching_sides.map { |n| 6 - n }.sum
# part 2
puts drop.count_facing_outside

drop = Drop.new('./inputs/day18.txt')
# part 1
puts drop.touching_sides.map { |n| 6 - n }.sum
# part 2
puts drop.count_facing_outside
