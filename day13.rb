# Day 13 of the advent of code 2022

# left and right are arrays
def compare(left, right)
    return nil if (left == []) and (right == [])

    return true if left == []

    return false if right == []

    a = left[0]
    b = right[0]

    return compare(left[1..], right[1..]) if (a.is_a? Integer) and (b.is_a? Integer) and (a == b)

    return a < b if (a.is_a? Integer) and (b.is_a? Integer)

    b = [b] if b.is_a? Integer
    if a.is_a? Integer
        ab = compare([a], b)
    elsif b.is_a? Integer
        ab = compare(a, [b])
    else
        ab = compare(a, b)
    end

    return ab unless ab.nil?

    return compare(left[1..], right[1..])
end

# Part 1

ordered = File.read("./inputs/day13.txt").split("\n\n").map.with_index do |lines, i|
    left, right = lines.split("\n").map { |line| eval(line) }
    [compare(left, right), i]
end.select { |bool, _| bool }.map { |_, i| i + 1 }

puts ordered.sum

# Part 2

packets = File.read("./inputs/day13.txt").split("\n").reject { |line| line.empty?}.map { |line| eval(line) }

position_second = packets.select { |packet| compare(packet, [[2]]) }.length + 1
position_sixth = packets.select { |packet| compare(packet, [[6]]) }.length + 2

puts position_second * position_sixth
