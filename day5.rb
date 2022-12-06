# Day 5 of the advent of code 2022

raw_input = File.read("inputs/day5.txt").split("\n")

stacks_input = raw_input[..7]
moves_input = raw_input[10..]

# puts stacks_input
# puts moves_input[..5]

def col_index(j)
    1 + 4 * j
end

def decode_stack(j, string_input)
    stack = []
    i = 7
    col = col_index(j)
    while (i >= 0) and (string_input[i].length > col) and (string_input[i][col] != " ") do
        stack.push(string_input[i][col])
        i -= 1
    end
    stack
end

stacks = Array.new(9, nil)
(0..8).each do |j|
    stacks[j] = decode_stack(j, stacks_input)
end

# puts stacks[-1]

moves = moves_input.map do |s|
    /move (\d+) from (\d+) to (\d+)/.match(s).captures.map &:to_i
end

# puts(moves[-1])

def apply_move_9000(move, stacks)
    n = move[0]
    j1 = move[1] - 1
    j2 = move[2] - 1
    stacks[j2].push(*stacks[j1].pop(n).reverse)
end

moves.each {|move| apply_move_9000(move, stacks)}

puts stacks.map {|l| l[-1]}.reduce {|a,b| a+b}

# regenerate stacks
stacks = Array.new(9, nil)
(0..8).each do |j|
    stacks[j] = decode_stack(j, stacks_input)
end

def apply_move_9001(move, stacks)
    n = move[0]
    j1 = move[1] - 1
    j2 = move[2] - 1
    stacks[j2].push(*stacks[j1].pop(n))
end

moves.each {|move| apply_move_9001(move, stacks)}

puts stacks.map {|l| l[-1]}.reduce {|a,b| a+b}
