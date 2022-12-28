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
def explore(volcano, room, opened, score, iteration, visited, opened_score)
    opened_score[opened.to_set] = [opened_score[opened.to_set], score].max
    # no time left !
    return score if iteration.zero?

    # which valves do we still have time to go open
    available = (volcano.rates.keys.to_set - opened.to_set).to_a.select do |name|
        !volcano.rates[name].zero? and (volcano.distances[room][name] + 1 <= iteration)
    end
    # can not go open any more valves !
    return score if available.empty?

    # for each valve that we can go open, compute the score
    scores = available.map do |name|
        new_iteration = iteration - volcano.distances[room][name] - 1
        explore(
            volcano,
            name,
            opened + [name],
            score + volcano.rates[name] * new_iteration,
            new_iteration,
            visited,
            opened_score
        )
    end
    # associate the max score to the current parameters and return it
    visited[room][[iteration, opened.to_set]] = scores.max
    visited[room][[iteration, opened.to_set]]
end

def max_pressure(volcano, minutes)
    # initialize visited rooms
    visited = {}
    volcano.rates.each_key { |name| visited[name] = {} }
    # initialize scores of opened configurations
    opened_score = Hash.new(0)
    # run the exploration
    score = explore(volcano, 'AA', ['AA'], 0, minutes, visited, opened_score)
    [score, opened_score]
end

volcano = Volcano.new('./inputs/day16.txt')

# part1
puts max_pressure(volcano, 30).first

# part2 (the product below takes a few minutes)
opened_score = max_pressure(volcano, 26).last
prods = opened_score.keys.product(opened_score.keys).reject do |a, b|
    (a - ['AA']).intersect?(b - ['AA'])
end
puts prods.map { |a, b| opened_score[a] + opened_score[b] }.max
