# Day 1 of the advent of code 2022

input = File.read('./inputs/day1.txt')

elf_calories = input.split("\n\n").map { |str| str.split("\n") }.map { |list| list.map(&:to_i).sum }

# NOTE: the block { |s| s.to_i } can be replaced by &:to_i to pass the function directly

puts elf_calories.max

puts elf_calories.sort[-3..-1].sum
