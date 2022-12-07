# Day 7 of the advent of code 2022

# implements a file
class File
    attr_reader :name, :size

    def initialize(name, size)
        @name = name
        @size = size.to_i
    end

    def to_s(indent)
        '  ' * indent + "- #{@name} (file, size=#{@size})\n"
    end
end

# implements a directory
class Directory
    attr_reader :name, :parent
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
        return if children

        @children = {}
        str.split("\n").each do |line|
            case line
            when /^dir (.+)$/
                name = Regexp.last_match(1)
                @children[name] = Directory.new(name, self)
            when /^(\d+) ([\w.]+)$/
                size = Regexp.last_match(1)
                name = Regexp.last_match(2)
                @children[name] = File.new(name, size)
            end
        end
    end

    def size
        @size ||= @children.each_value.map(&:size).sum
        @size
    end

    def to_s(indent = 0)
        desc = '  ' * indent + "- #{@name} (dir, size=#{size})\n"
        desc + @children.each_value.map { |elem| elem.to_s(indent + 1) }.join('')
    end
end

def directory_from_file(path)
    fs = Directory.new('/', nil)
    current = fs
    File.read(path).split('$ ').each do |command|
        case command
        when /^cd \.\./
            current = current.parent
        when /^cd (\w+)$/
            current = current.children[Regexp.last_match(1)]
        when /^ls/
            current.process_list(command)
        end
    end
    fs
end

def sum_small_dir_sizes(fs, limit = 100_000)
    return 0 if fs.instance_of?(File)

    # fs is a Directory
    own_size = fs.size <= limit ? fs.size : 0
    own_size + fs.children.each_value.map { |dir| sum_small_dir_sizes(dir) }.sum
end

fs = directory_from_file('./inputs/day7.txt')

puts sum_small_dir_sizes(fs)

max_size = 70_000_000
necessary = 30_000_000

min_to_delete = fs.size - (max_size - necessary)

puts min_to_delete

def min_max_dir_size(fs, limit)
    return Float::INFINITY if fs.instance_of?(File)
    return [fs.size, fs.children.each_value.map { |dir| min_max_dir_size(dir, limit) }.min].min if fs.size >= limit

    Float::INFINITY
end

puts min_max_dir_size(fs, min_to_delete)
