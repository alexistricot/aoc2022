# Day 2 of the advent of code 2022

trad = { 'A' => 1, 'B' => 2, 'C' => 3, 'X' => 1, 'Y' => 2, 'Z' => 3 }

input = File.read('./inputs/day2.txt').split("\n").map { |s| s.split(' ').map { |code| trad[code] } }

def score(a, b)
  b + 3 * ((b - a + 1) % 3)
end

puts input.map { |l| score(l[0], l[1]) }.sum

def second_score(a, b)
  case b
  when 1
    ((a - 2) % 3) + 1
  when 2
    a + 3
  else
    (a % 3) + 1 + 6
  end
end

puts input.map { |l| second_score(l[0], l[1]) }.sum
