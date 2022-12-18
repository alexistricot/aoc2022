# Day 14 of the advent of code 2022

class Cave
    def initialize(path)
        text = File.read(path)
        @width = 2 * (1 + text.scan(/(\d+),\d+/).map(&:first).map(&:to_i).max)
        @height = 3 + text.scan(/\d+,(\d+)/).map(&:first).map(&:to_i).max
        @map = Array.new(@width) { Array.new(@height, 0) }
        text.split("\n").each do |line|
            line.split(' -> ').each_cons(2) do |start, finish|
                i, j = start.split(',').map(&:to_i)
                k, l = finish.split(',').map(&:to_i)
                if i == k
                    @map[i][[j, l].min..[j, l].max] = Array.new((l - j).abs + 1, 2)
                else
                    @map[[i, k].min..[i, k].max].each { |row| row[j] = 2 }
                end
            end
        end
    end

    def print
        letter = { 0 => '.', 1 => 'o', 2 => '#' }
        @map.transpose.each do |row|
            puts row.map { |i| letter[i] }.join('')
        end
    end

    def pour_sand(i, j)
        return false if j == @height - 1

        @map[i][j] = 1
        if @map[i][j + 1].zero?
            @map[i][j] = 0
            @map[i][j + 1] = 1
            pour_sand(i, j + 1)
        elsif @map[i - 1][j + 1].zero?
            @map[i][j] = 0
            @map[i - 1][j + 1] = 1
            pour_sand(i - 1, j + 1)
        elsif @map[i + 1][j + 1].zero?
            @map[i][j] = 0
            @map[i + 1][j + 1] = 1
            pour_sand(i + 1, j + 1)
        else
            true
        end
    end

    def add_floor
        @map.each { |row| row[-1] = 2 }
    end

    def pour_all_sand(i, j)
        return false unless @map[500][0].zero?

        @map[i][j] = 1
        if @map[i][j + 1].zero?
            @map[i][j] = 0
            @map[i][j + 1] = 1
            pour_all_sand(i, j + 1)
        elsif @map[i - 1][j + 1].zero?
            @map[i][j] = 0
            @map[i - 1][j + 1] = 1
            pour_all_sand(i - 1, j + 1)
        elsif @map[i + 1][j + 1].zero?
            @map[i][j] = 0
            @map[i + 1][j + 1] = 1
            pour_all_sand(i + 1, j + 1)
        else
            true
        end
    end
end

# part 1

cave = Cave.new('./inputs/day14.txt')

i = 0
i += 1 while cave.pour_sand(500, 0)

# puts i

# part 2

cave = Cave.new('./inputs/day14.txt')
cave.add_floor

cave.print

i = 0
i += 1 while cave.pour_all_sand(500, 0)

# puts i
