# Day 20 of the advent of code 2022

class Circular
    def initialize(numbers)
        @numbers = numbers
        @n = numbers.length
        # position of each number in the list
        @position = Array(@n.times)
    end

    def move(i)
        number = @numbers[i]
        # first we consider the element removed
        # update positions after the element leaves
        @position = @position.map { |n| n > @position[i] ? n - 1 : n }
        # the list in which to insert it back is of length @n - 1
        new_position = (@position[i] + number) % (@n - 1)
        # update the positions after the element is added
        @position = @position.map { |n| n >= new_position ? n + 1 : n }
        @position[i] = new_position
    end

    def get(j)
        position = (@position[@numbers.index(0)] + j) % @n
        @numbers[@position.index(position)]
    end

    def run
        @numbers.each_index { |i| move(i) }
        # print
    end

    def print
        puts Array(@n.times).map { |j| @numbers[@position.index(j)] }.join(' ')
    end
end

input = './inputs/day20.txt'
# input = './inputs/day20.test.txt'

# part 1
numbers = Array(File.read(input).split("\n").map(&:to_i))
circular = Circular.new(numbers)
circular.run
puts circular.get(1000) + circular.get(2000) + circular.get(3000)

# part 2
decryption_key = 811_589_153
numbers = Array(File.read(input).split("\n").map(&:to_i).map { |n| n * decryption_key })
circular = Circular.new(numbers)
10.times { |_| circular.run }
puts circular.get(1000) + circular.get(2000) + circular.get(3000)
