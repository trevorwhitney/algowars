require 'pry'

class Divider
  attr_reader :n, :m, :times, :speeds

  def initialize(file)
    file = File.open(file, "r")
    lines = file.readlines
    @n = lines[0].strip.to_i
    @m = lines[1].strip.to_i
    @times = lines[2].split(" ").map {|e| e.strip.to_i}.sort
    @speeds = lines[3].split(" ").map {|e| e.strip.to_i}.sort
  end

  def completion_time
    groups = generate_groups
    totals = Hash.new()
    results = Array.new(@m)

    processes = @n

    # initially give each machine the largest from their group
    @m.times do |i|
      if totals[i].nil?
        totals[i] = groups[i].pop / (@speeds[i] * 1.0)
        processes -= 1
      end
    end

    while processes > 0
      # find the lowest time
      finished = totals.sort_by {|k,v| v}[0][0]
      #binding.pry

      # give that process it's next biggest
      if groups[finished].size > 0
        totals[finished] += groups[finished].pop / (@speeds[finished] * 1.0)
        processes -= 1
      # only go up 1
      elsif groups[finished + 1] && groups[finished + 1].size > 0
        totals[finished] += groups[finished + 1].delete_at(0) / (@speeds[finished] * 1.0)
        processes -= 1
      # go down at least 2...change this to unlimited?
      elsif groups[finished - 1] && groups[finished - 1].size > 0
        totals[finished] += groups[finished - 1].pop / (@speeds[finished] * 1.0)
        processes -= 1
      elsif groups[finished - 2] && groups[finished - 2].size > 0
        totals[finished] += groups[finished - 2].pop / (@speeds[finished] * 1.0)
        processes -= 1
      else
        #this guy is done, remove from pool
        results[finished] = totals[finished]
        totals.delete_at(finished)
      end
    end

    totals.each do |k,v|
      results[k] = v
    end

    return results.sort[-1]
  end

  def generate_groups
    size = @n / @m
    remainder = @n % @m
    groups = []
    @m.times do |i|
      groups << @times[(size*i)..(size*(i+1))-1]
    end
    remainder.times do |i|
      groups[-1] << @times[-(i+1)]
    end

    return groups
  end
end