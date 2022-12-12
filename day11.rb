# Day 11 of the advent of code 2022

class Monkey
    attr_accessor :inspected, :test, :max_range

    def initialize(description)
        @items = []
        @inspected = 0
        @max_range = 0
        description.split("\n").each do |line|
            case line
            when /Starting items: (.*)$/
                @items = $1.split(',').map { |s| s.strip.to_i }
            when /Operation: new = (.*)$/
                @operation = $1
            when /Test: divisible by (\d+)/
                @test = $1.to_i
            when /If true: throw to monkey (\d+)/
                @true_monkey = $1.to_i
            when /If false: throw to monkey (\d+)/
                @false_monkey = $1.to_i
            end
        end
    end

    def run_round
        @items.each do |i|
            @inspected += 1
            u = update(i)
            if (u % @test).zero?
                yield [u, @true_monkey]
            else
                yield [u, @false_monkey]
            end
        end
        @items = []
    end

    def update(_item)
        eval(@operation.gsub('old', '_item')) % max_range
    end

    def receive(item)
        @items.push(item)
    end
end

# Part 1
monkeys = File.read('./inputs/day11.txt').split("\n\n").map { |desc| Monkey.new(desc) }

max_range = monkeys.map(&:test).inject(:*)

monkeys.each { |monkey| monkey.max_range = max_range }

20.times do |_|
    monkeys.each do |monkey|
        monkey.run_round do |(item, j)|
            monkeys[j].receive(item)
        end
    end
end

puts monkeys.map(&:inspected).max(2).inject(:*)

# Part 2

monkeys = File.read('./inputs/day11.txt').split("\n\n").map { |desc| Monkey.new(desc) }

max_range = monkeys.map(&:test).inject(:*)

monkeys.each { |monkey| monkey.max_range = max_range }

10_000.times do |_|
    monkeys.each do |monkey|
        monkey.run_round do |(item, j)|
            monkeys[j].receive(item)
        end
    end
end

puts monkeys.map(&:inspected).max(2).inject(:*)
