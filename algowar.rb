require './divider.rb'

# Instantiate divider with command line input
# Print results

unless ARGV[0] && ARGV[0].size > 0
  puts "Please provide an input file"
  exit!
end

@divider = Divider.new(ARGV[0])
puts "#{@divider.to_s}"