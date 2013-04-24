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

    unless @times.size == @n && @speeds.size == @m
      raise InvalidParam.new("Invalid input, list of times or speeds" + 
        "does not match number of tasks or machines specified.")
    end
  end

  
  # when pulling from the next group up
  # if the time it would take the slower machine to do the task
  # is one order of magnitude greater than the current elapsed time
  # of the faster computer, then don't take the task, and continue looking below
  def completion_time
    groups = generate_groups
    totals = Hash.new()
    results = Array.new(@m)

    processes = @n

    # initially give each machine the largest from their group
    @m.times do |i|
      if totals[i].nil?
        puts "#{i} taking #{groups[i][-1]}"
        totals[i] = groups[i].pop / (@speeds[i] * 1.0)
        processes -= 1
      end
    end

    while processes > 0
      # find the lowest time
      sorted_totals = totals.sort_by {|k,v| v}
      finished = sorted_totals[0][0]
      finished_time = sorted_totals[0][1]

      # tie breaker
      if sorted_totals[1][1] == finished_time
        i = 1
        while sorted_totals[i][1] == finished_time
          i += 1
        end
        tied = []
        i.times do |j|
          tied << sorted_totals[j][0]
        end
        tied.sort
        finished = tied[-1]
      end

      # give that process it's next biggest
      if groups[finished].size > 0
        puts "#{finished} taking #{groups[finished][-1]}"
        totals[finished] += groups[finished].pop / (@speeds[finished] * 1.0)
        processes -= 1
      # only go up 1
      # that it can go up 1
      elsif groups[finished + 1] && groups[finished + 1].size > 0
        puts "#{finished} going up 1"
        puts "#{finished} taking #{groups[finished + 1][-1]}"
        totals[finished] += groups[finished + 1].delete_at(0) / (@speeds[finished] * 1.0)
        processes -= 1
      # go down at least 2...change this to unlimited?
      
      # change to while, iterate down groups
      else
        index = finished - 1
        operation = 0
        while index >= 0
          if groups[index] && groups[index].size > 0
            totals[finished] += groups[index].pop / (@speeds[finished] * 1.0)
            operation = 1
            processes -= 1
            index = -1
          else
            index -= 1
          end
        end

        if operation == 0
          results[finished] = totals[finished]
          totals.delete(finished)
        end
      end

      elsif groups[finished - 1] && groups[finished - 1].size > 0 && finished > 0
        puts "#{finished} going down 1"
        puts "#{finished} taking #{groups[finished - 1][-1]}"
        totals[finished] += groups[finished - 1].pop / (@speeds[finished] * 1.0)
        processes -= 1
      elsif groups[finished - 2] && groups[finished - 2].size > 0 && finished > 1
        puts "#{finished} going down 2"
        puts "#{finished} taking #{groups[finished - 2][-1]}"
        totals[finished] += groups[finished - 2].pop / (@speeds[finished] * 1.0)
        processes -= 1
      else
        #this guy is done, remove from pool
        results[finished] = totals[finished]
        totals.delete(finished)
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

  class InvalidParam < ArgumentError; end
end