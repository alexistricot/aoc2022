# Day 12 of the advent of code 2022

require 'set'

class Position
    attr_accessor :neighbors, :elevation, :i, :j, :distance, :visited, :letter, :previous

    def initialize(letter, i, j)
        @letter = letter
        @elevation = case letter
                     when 'S'
                         1
                     when 'E'
                         26
                     else
                         letter.each_byte.first - 97 + 1
                     end
        @i = i
        @j = j
        @neighbors = []
        @distance = Float::INFINITY
        @visited = false
        @previous = nil
    end

    def is_source
        @letter == 'S'
    end

    def is_target
        @letter == 'E'
    end

    def indices
        [@i, @j]
    end
end

class Map
    attr_accessor :target, :source

    def initialize(path)
        @vertices = []
        matrix = File.read(path).split("\n").map { |line| line.split('') }
        @nrows = matrix.length
        @ncols = matrix[0].length
        # add vertices
        matrix.each.with_index do |row, i|
            row.each.with_index do |letter, j|
                position = Position.new(letter, i, j)
                if position.is_source
                    @source = position
                elsif position.is_target
                    @target = position
                end
                @vertices.push(position)
            end
        end
    end

    def as_mat(i, j)
        @vertices[i * @ncols + j]
    end

    def build_edges(uphill)
        # uphill argument tells us if we go uphill or downhill
        @vertices.each do |position|
            [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |di, dj|
                i = position.i + di
                j = position.j + dj
                next unless (i >= 0) and (j >= 0) and (i < @nrows) and (j < @ncols)

                neighbor = as_mat(i, j)
                position.neighbors.push(neighbor) if uphill and (neighbor.elevation - position.elevation) <= 1
                position.neighbors.push(neighbor) if !uphill and (neighbor.elevation - position.elevation) >= -1
            end
        end
    end

    def dijkstra(i, j)
        # initialize vertices
        @unvisited = [].to_set
        @vertices.each do |pos|
            pos.visited = false
            pos.distance = Float::INFINITY
        end
        # start from the position in arguments
        current = as_mat(i, j)
        current.distance = 0
        current.visited = true
        propagate(current)
    end

    def propagate(current)
        current.neighbors.each do |neighbor|
            next if neighbor.visited

            if current.distance + 1 < neighbor.distance
                neighbor.distance = current.distance + 1
                neighbor.previous = current
            end
            @unvisited.add(neighbor.indices)
        end
        current.visited = true
        @unvisited -= [current.indices]
        return if @unvisited.empty?

        ind_min_dist = @unvisited.map { |ind| [as_mat(*ind).distance, ind] }.min.last

        propagate(as_mat(*ind_min_dist))
    end

    def closest_letter(letter)
        i, j = @vertices.select { |pos| pos.letter == letter }.map { |pos| [pos.distance, pos.indices] }.min.last
        as_mat(i, j)
    end

    # print the visited letters, in order
    def print_visited
        @vertices.each_slice(@ncols) do |row|
            puts row.map { |pos| pos.visited ? pos.letter : '.' }.join('')
        end
    end

    # return the path of visited positions as an array of Position, from a position's indices
    def path(i, j)
        current = as_mat(i, j)
        path = [current]
        until current.previous.nil?
            current = current.previous
            path.push(current)
        end
        path
    end

    # print the path on the map which arrives at a given position
    def print_path(i, j)
        lines = Array.new(@nrows) { '.' * @ncols }
        lines[i][j] = as_mat(i, j).letter
        path(i, j).each do |current|
            next if current.previous.nil?

            ip, jp = current.previous.indices
            ic, jc = current.indices
            case ic - ip
            when 1
                c = 'v'
            when -1
                c = '^'
            end
            case jc - jp
            when 1
                c = '>'
            when -1
                c = '<'
            end
            lines[ip][jp] = c
        end
        lines.join("\n")
    end
end

# First part

# go uphill and start from source
map = Map.new('./inputs/day12.txt')
map.build_edges(true)
map.dijkstra(*map.source.indices)

puts map.target.distance

File.write('day_12_first_part.txt', map.print_path(*map.target.indices))

# Second part

# go downhill and start from target
map = Map.new('./inputs/day12.txt')
map.build_edges(false)
map.dijkstra(*map.target.indices)

puts map.closest_letter('a').distance

File.write('day_12_second_part.txt', map.print_path(*map.closest_letter('a').indices))
