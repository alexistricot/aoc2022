# Day 16 of the advent of code 2022

require 'set'

class Volcano
    attr_reader :tunnels, :max_rate, :rates, :distances

    def initialize(path)
        @rates = {}
        @tunnels = {}
        @max_rate = 0
        File.read(path).split("\n").each do |line|
            re = /^Valve ([A-Z]{2}) has flow rate=(\d+); tunnels? leads? to valves? (.*)$/
            name, rate, tunnels = re.match(line).captures
            @rates[name] = rate.to_i
            @max_rate += rate.to_i
            @tunnels[name] = tunnels.split(', ')
        end
        build_paths
    end

    def flow(opened)
        opened.map { |room| @rates[room] }.sum
    end

    def build_paths
        @distances = {}
        @rates.each_key do |name|
            @distances[name] = get_paths_from(name)
        end
    end

    def get_paths_from(name)
        dist = 0
        currents = [name]
        distances = {}
        until currents.empty?
            next_nodes = []
            dist += 1
            currents.each do |n|
                @tunnels[n].each do |dest|
                    unless distances.keys.include?(dest) || dest == name
                        next_nodes.append(dest)
                        distances[dest] = dist
                    end
                end
            end
            currents = next_nodes
        end
        distances
    end
end

# Args:
#   volcano (Volcano): the volcano, with @distances filled
#   room (String): the current room
#   opened (Array[String]): the rooms with valves currently opened
#   score (Integer): the current score
#   iteration (Integer): the nuber of minutes remaining
#   visited (Hash[String, Hash]): for each room, what score was affected with a
#       given iteration and set of opened valves.
def explore(volcano, room, opened, score, iteration, visited)
    # no time left !
    return score if iteration.zero?

    # which valves do we still have time to go open
    available = (volcano.rates.keys.to_set - opened.to_set).to_a.select do |name|
        (volcano.distances[room][name] + 1 <= iteration) and !volcano.rates[name].zero?
    end
    # can not go open any more valves !
    return score if available.empty?
    # return if the current room was already visited with those parameters
    return visited[room][[iteration, opened.to_set]] if visited[room].include?([iteration, opened.to_set])

    # for each valve that we can go open, compute the score
    scores = available.map do |name|
        new_iteration = iteration - volcano.distances[room][name] - 1
        explore(
            volcano,
            name,
            opened + [name],
            score + volcano.rates[name] * new_iteration,
            new_iteration,
            visited
        )
    end
    # associate the max score to the current parameters and return it
    visited[room][[iteration, opened.to_set]] = scores.max
    visited[room][[iteration, opened.to_set]]
end

volcano = Volcano.new('./inputs/day16.txt')

visited = {}
volcano.rates.each_key { |name| visited[name] = {} }

# part1
# puts explore(volcano, 'AA', ['AA'], 0, 30, visited)

def explore_with_elephant(volcano, room_human, room_elephant, opened, score, iteration_human, iteration_elephant,
                          visited)
    # no time left !
    return score if iteration_human.zero? and iteration_elephant.zero?

    rooms = [room_human, room_elephant].to_set
    iterations = [iteration_human, iteration_elephant].to_set
    if visited.keys.include?([iterations, rooms, opened.to_set])
        # puts "Visited #{[iterations, rooms,
        #                  opened.to_set].join(' ')}: score #{visited[[iterations, rooms, opened.to_set]]}"
        return visited[[iterations, rooms, opened.to_set]]
    end

    # which valves do we still have time to go open
    available_human = (volcano.rates.keys.to_set - opened.to_set).to_a.select do |name|
        (volcano.distances[room_human][name] + 1 <= iteration_human) and !volcano.rates[name].zero?
    end
    available_elephant = (volcano.rates.keys.to_set - opened.to_set).to_a.select do |name|
        (volcano.distances[room_elephant][name] + 1 <= iteration_elephant) and !volcano.rates[name].zero?
    end
    # can not go open any more valves !
    return score if available_human.empty? and available_elephant.empty?

    # handle the case where only the elephant can move
    if available_human.empty?
        scores = available_elephant.map do |name_elephant|
            new_iteration_elephant = iteration_elephant - volcano.distances[room_elephant][name_elephant] - 1
            # puts iteration_human, new_iteration_elephant
            explore_with_elephant(
                volcano,
                room_human,
                name_elephant,
                opened + [name_elephant],
                score + volcano.rates[name_elephant] * new_iteration_elephant,
                iteration_human,
                new_iteration_elephant,
                visited
            )
        end
        visited[[iterations, rooms, opened.to_set]] = scores.max
        return scores.max
    end
    # handle the case where only the human can move
    if available_elephant.empty?
        scores = available_human.map do |name_human|
            new_iteration_human = iteration_human - volcano.distances[room_human][name_human] - 1
            # puts new_iteration_human, iteration_elephant
            explore_with_elephant(
                volcano,
                name_human,
                room_elephant,
                opened + [name_human],
                score + volcano.rates[name_human] * new_iteration_human,
                new_iteration_human,
                iteration_elephant,
                visited
            )
        end
        visited[[iterations, rooms, opened.to_set]] = scores.max
        return scores.max
    end
    # define the pairs of valves that can be opened
    available = available_human.product(available_elephant).reject do |name_human, name_elephant|
        name_human == name_elephant
    end
    return score if available.empty?

    # for each pair of valves, get the best score
    scores = available.map do |name_human, name_elephant|
        new_iteration_human = iteration_human - volcano.distances[room_human][name_human] - 1
        new_iteration_elephant = iteration_elephant - volcano.distances[room_elephant][name_elephant] - 1
        explore_with_elephant(
            volcano,
            name_human,
            name_elephant,
            opened + [name_human, name_elephant],
            score + volcano.rates[name_human] * new_iteration_human + volcano.rates[name_elephant] * new_iteration_elephant,
            new_iteration_human,
            new_iteration_elephant,
            visited
        )
    end
    visited[[iterations, rooms, opened.to_set]] = scores.max
    scores.max
end

# part 2
visited = {}
puts explore_with_elephant(volcano, 'AA', 'AA', ['AA'], 0, 26, 26, visited)
