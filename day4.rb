# Day 4 of the advent of code 2022

input = File.read('inputs/day4.txt').split("\n")

class Assignments
    def initialize(s)
        l = s.split(',')
        @start1 = l[0].split('-').first.to_i
        @end1 = l[0].split('-').last.to_i
        @start2 = l[1].split('-').first.to_i
        @end2 = l[1].split('-').last.to_i
    end

    def is_contained
        (@start1 >= @start2 and @end1 <= @end2) or (@start2 >= @start1 and @end2 <= @end1)
    end

    def is_overlapping
        @start1 <= @end2 and @start2 <= @end1
    end
end

assign = input.map { |s| Assignments.new(s) }

puts assign.count(&:is_contained)
puts assign.count(&:is_overlapping)
