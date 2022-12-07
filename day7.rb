# Day 7 of the advent of code 2022

class File
    attr_reader :name
    attr_reader :size

    def initialize(name, size)
        @name=name
        @size=size.to_i
    end

    def to_s(indent)
        "  " * indent + "- #{@name} (file, size=#{@size})\n"
    end
end

class Directory
    attr_reader :name
    attr_reader :parent
    attr_reader :size
    attr_accessor :children

    def initialize(name, parent)
        # when creating a directory, we only discovered it with ls ;
        # we do not have any information on size nor children yet
        @size = nil
        @children = nil
        @name = name
        @parent = parent
    end

    def process_list(str)
        if children
            # we already listed the contents
            return
        end
        @children = Hash.new()
        str.split("\n").each do |line|
            case line
            when /^dir .+$/ then
                name = /^dir (.+)$/.match(line).captures.first
                @children[name] = Directory.new(name, self)
            when /^\d+ [\w\.]+$/ then
                size, name = /^(\d+) ([\w\.]+)$/.match(line).captures
                @children[name] = File.new(name, size)
            end
        end
    end

    def size()
        if not @size
            @size = @children.each_value.map(&:size).sum
        end
        return @size
    end

    def to_s(indent=0)
        "  " * indent + "- #{@name} (dir, size=#{self.size})\n" + @children.each_value.map { |elem| elem.to_s(indent + 1)}.join("")
    end
end

def directory_from_file(path)
    fs = Directory.new("/", nil)
    current = fs

    File.read(path).split("$ ").each do |command|
        case command
        when /^cd \.\./
            current = current.parent
        when /^cd \w+$/
            name = /^cd ([\w]+)$/.match(command).captures.first
            current = current.children[name]
        when /^ls/
            current.process_list(command)
        end
    end
    return fs
end


def sum_small_dir_sizes(fs, limit=100000)
    if fs.class == File
        return 0
    end
    # fs is a Directory
    own_size = fs.size <= limit ? fs.size : 0
    return own_size + fs.children.each_value.map { |dir| sum_small_dir_sizes(dir) }.sum
end

fs = directory_from_file("./inputs/day7.txt")

puts sum_small_dir_sizes(fs)

max_size = 70000000
necessary = 30000000

min_to_delete = fs.size - (max_size - necessary)

puts min_to_delete

def min_max_dir_size(fs, limit)
    if fs.class == File
        return 1.0 / 0.0
    end
    if fs.size >= limit
        return [fs.size, fs.children.each_value.map { |dir| min_max_dir_size(dir, limit) }.min].min
    else
        return 1.0 / 0.0
    end
end

puts min_max_dir_size(fs, min_to_delete)
