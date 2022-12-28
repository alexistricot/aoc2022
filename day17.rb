# Day 17 of the advent of code 2022

class Rock
    attr_accessor :positions, :height

    def initialize(string, spawn_height)
        case string
        when '-'
            @positions = [[spawn_height, 2], [spawn_height, 3], [spawn_height, 4], [spawn_height, 5]]
        when '+'
            @positions = [[spawn_height, 3], [spawn_height + 1, 2], [spawn_height + 1, 3],
                          [spawn_height + 1, 4], [spawn_height + 2, 3]]
        when 'J'
            @positions = [[spawn_height, 2], [spawn_height, 3], [spawn_height, 4], [spawn_height + 1, 4],
                          [spawn_height + 2, 4]]
        when '|'
            @positions = [[spawn_height, 2], [spawn_height + 1, 2], [spawn_height + 2, 2], [spawn_height + 3, 2]]
        when 'o'
            @positions = [[spawn_height, 2], [spawn_height + 1, 2], [spawn_height, 3], [spawn_height + 1, 3]]
        else
            raise "Unknown type #{string}"
        end
    end

    def move(dy, dx)
        @positions.map { |y, x| [y + dy, x + dx] }
    end

    def max_height
        @positions.map(&:first).max
    end
end

class Tower
    attr_reader :max_height

    def initialize(n)
        @rock_types = '-+J|o'
        @max_height = -1
        @rock = nil
        @matrix = Array.new(n * 2) { Array.new(7, false) }
        @moves = 0
    end

    def spawn_height
        @max_height + 4
    end

    def push(string)
        # puts visualize
        # puts "\n"
        case string
        when '<'
            new_positions = @rock.move(0, -1)
            @rock.positions = new_positions unless conflict?(new_positions)
            @moves += 1
            true
        when '>'
            new_positions = @rock.move(0, 1)
            @rock.positions = new_positions unless conflict?(new_positions)
            @moves += 1
            true
        when 'v'
            new_positions = @rock.move(-1, 0)
            @rock.positions = new_positions unless conflict?(new_positions)
            !conflict?(new_positions)
        end
    end

    def spawn_rock(string)
        @rock = Rock.new(string, spawn_height)
    end

    def conflict?(positions)
        positions.any? do |y, x|
            y.negative? or x.negative? or (x > 6) or @matrix[y][x]
        end
    end

    def resolve(input, n, fold)
        jets = input.strip.split('').cycle
        first_pattern = []
        current_pattern = []
        last_repeat = 0
        n.times.zip(@rock_types.split('').cycle) do |i, type|
            spawn_rock(type)
            # puts visualize
            # puts "\n"
            push(jets.next)
            push(jets.next) while push('v')
            @rock.positions.each { |y, x| @matrix[y][x] = true }
            height_diff = [@max_height, @rock.max_height].max - @max_height
            j = i + 1 # current number of rocks that have fallen
            current_pattern.push(height_diff)
            first_pattern.push(height_diff) if j <= fold
            puts "First pattern #{first_pattern.join(',')}" if j == fold
            if (j % fold).zero?
                # puts current_pattern.join(',')
                if current_pattern == first_pattern
                    puts "#{fold}-fold Initial pattern repeating: j=#{j}, delta=#{j - last_repeat}, height=#{@max_height}"
                    last_repeat = j
                end
                current_pattern = []
            end
            @max_height = [@max_height, @rock.max_height].max
        end
    end

    def visualize
        max = @max_height + 7
        lines = @matrix[0..max].map { |row| row.map { |b| b ? '#' : '.' }.join('') }
        @rock.positions.each { |y, x| lines[y][x] = '@' }
        lines.reverse.join("\n")
    end
end

n = 3840
fold = 100
input = File.read('./inputs/day17.txt')
tower = Tower.new(n)
tower.resolve(input, n, fold)
# puts tower.visualize
puts tower.max_height + 1

# this prints the repeats of the first pattern (a pattern being the successive height added by 5 rocks)
# their is a repetition of the apparition of the first pattern which will allow us to
# locate a general repetition of the process
#
# the pattern starts at j = 930 and starts repeating at j = 2690, making it 1760 rocks long
# the pattern starts at height = 1481 and starts repeating at height 4218, making it 2737 rocks high
#
# hence after 1_000_000_000_000 rocks, we will have 930 rocks falling at the start,
# then (1_000_000_000_000 - 930) / 1760 = 568_181_817 patterns are repeating
# and there are (1_000_000_000_000 - 930) % 1760 = 1150 rocks left to fall
#
# To identify the height that these 1150 rocks will generate at the end, we run
# a simulation of 2690 + 1150 = 3840 rocks (2690 is the start of the second pattern repeat)
# and we will remove the height of the first 2690 rocks: 4218
#
# Height after 3840 rocks: 5993 so the height of the 1150 final rocks is 5993 - 4218 = 1775
# hence the answer is:

puts 1481 + 2737 * 568_181_817 + 1775
# 1_555_113_636_385 Yay !

# Could have implemented a proper detection of the repetition of the patterns
# although I'm actually glad to have solved the second part "manually", it's cool
# to have a combination of programming and simple maths
