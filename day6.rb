# Day 6 of the advent of code

require 'set'

uniques = []

File.read('./inputs/day6.txt').split('').each_cons(4).with_index do |window, i|
    uniques.push(i) if window.to_set.length == window.length
end

puts uniques[0] + 4

messages = []

File.read('./inputs/day6.txt').split('').each_cons(14).with_index do |window, i|
    messages.push(i) if window.to_set.length == window.length
end

puts messages[0] + 14
