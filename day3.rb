# Day 3 of the advent of code 2022

require 'set'

input_unsplit = File.read('inputs/day3.txt').split("\n").map { |s| s.split('') }
input = input_unsplit.map { |l| [l[0..l.length / 2 - 1], l[l.length / 2..]] }

def priority(s)
  n = s.each_byte.first
  if n >= 97
    n - 97 + 1
  else
    n - 65 + 27
  end
end

def get_double(l1, l2)
  (l1.to_set & l2.to_set).first
end

puts input.map { |l| get_double(l[0], l[1]) }.map { |s| priority(s) }.sum

def get_badge(l1, l2, l3)
  (l1.to_set & l2.to_set & l3.to_set).first
end

badges = []
input_unsplit.each_slice(3) { |l1, l2, l3| badges.push(get_badge(l1, l2, l3)) }
puts badges.map { |s| priority(s) }.sum
