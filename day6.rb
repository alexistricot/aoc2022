# Day 6 of the advent of code

require "set"

uniques = []

input = File.read("./inputs/day6.txt").split("").each_cons(4).with_index do |window, i|
    if window.to_set.length == window.length
        uniques.push(i)
    end
end

puts uniques[0] + 4

messages = []

input = File.read("./inputs/day6.txt").split("").each_cons(14).with_index do |window, i|
    if window.to_set.length == window.length
        messages.push(i)
    end
end

puts messages[0] + 14
