# Day 10 of the advent of code 2022

class CPU
    attr_accessor :memory

    def initialize
        @cycle = 1
        @counter = 1
        @memory = [1]
    end

    def run(command)
        case command
        when /^noop$/
            @cycle += 1
            @memory.push(@counter)
        when /^addx (-?)(\d+)$/
            @cycle += 2
            @memory.push(@counter)
            sign = ::Regexp.last_match(1).empty? ? +1 : -1
            @counter += sign * ::Regexp.last_match(2).to_i
            @memory.push(@counter)
        end
    end

    def signal_strength(i)
        i * @memory[i - 1]
    end

    def print
        @memory.each.with_index { |counter, cycle| puts "Cycle #{cycle + 1}, X=#{counter}" }
    end
end

commands = File.read('./inputs/day10.txt').split("\n")

cpu = CPU.new

commands.each { |command| cpu.run(command) }

# cpu.print

cycles = [20, 60, 100, 140, 180, 220]

puts cycles.map { |i| cpu.signal_strength(i) }.sum

class Screen
    def initialize(commands)
        @cpu = CPU.new
        commands.each { |command| @cpu.run(command) }
        @pixels = @cpu.memory.map.with_index do |x, i|
            ((x - i + 1) % 40) <= 2
        end
    end

    def print
        @pixels.each_slice(40) do |slice|
            puts slice.map { |b| b ? '#' : '.' }.join('')
        end
    end
end

Screen.new(commands).print
