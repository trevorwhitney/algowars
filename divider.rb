require 'pry'
require 'active_support/core_ext'

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

  def find_best_time
    results_1 = completion_time(:decision => :elapsed_time)
    results_2 = completion_time(:decision => :task_time)
    @final_results = results_1[:time] < results_2[:time] ? results_1 : results_2
  end

  def completion_time(options = {})
    options.reverse_merge!({ :decision => :elapsed_time })
    groups = generate_groups
    totals = Hash.new()
    results = Array.new(@m)
    machine_traces = Array.new(@m)
    machine_traces.each_index do |i|
      machine_traces[i] = []
    end

    processes = @n

    # initially give each machine the largest from their group
    @m.times do |i|
      if totals[i].nil?
        task = groups[i].pop
        machine_traces[i] << @times.find_index(task)
        totals[i] = task / (@speeds[i] * 1.0)
        processes -= 1
      end
    end

    while processes > 0
      # find the lowest time
      sorted_totals = totals.sort_by {|k,v| v}
      finished = sorted_totals[0][0]
      finished_time = sorted_totals[0][1]

      # tie breaker
      if sorted_totals[1] && sorted_totals[1][1] == finished_time
        i = 1
        while sorted_totals[i] && sorted_totals[i][1] == finished_time
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
        task = groups[finished].pop
        machine_traces[finished] << @times.find_index(task)
        totals[finished] += task / (@speeds[finished] * 1.0)
        processes -= 1
      # take the smallest from the next group up
      elsif groups[finished + 1] && groups[finished + 1].size > 0 && 
          allowed_to_take?(finished, finished + 1, groups, totals, 
          options[:decision])
        task = groups[finished + 1].delete_at(0)
        machine_traces[finished] << @times.find_index(task)
        totals[finished] += task / (@speeds[finished] * 1.0)
        processes -= 1
      # take the largest from as far down as it needs to go
      else
        index = finished - 1
        operation = 0
        while index >= 0
          if groups[index] && groups[index].size > 0
            task = groups[index].pop
            machine_traces[finished] << @times.find_index(task)
            totals[finished] += task / (@speeds[finished] * 1.0)
            operation = 1
            processes -= 1
          end
            
          index -= 1
        end

        #it didn't find a task to do, so this machine is done
        if operation == 0
          results[finished] = totals[finished]
          totals.delete(finished)
        end
      end
    end

    totals.each do |k,v|
      results[k] = v
    end


    return {:trace => machine_traces, :time => results.sort[-1]}
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

  def allowed_to_take?(current_index, bigger_index, groups, totals, decision)
    # check to see if the time it would take to do the task is
    # one order of magnitude more than the current elapsed time of
    # the faster machine. If it is, take the next task.
    time_of_task = groups[current_index + 1][0] / (@speeds[current_index] * 1.0)
    if decision == :elapsed_time
      elapsed_time = totals[bigger_index]
    else #do task time
      elapsed_time = groups[bigger_index][0] / (@speeds[bigger_index] * 1.0)
    end
    time_of_task.to_i.to_s.size <= elapsed_time.to_i.to_s.size
  end

  def to_s
    output = ""
    find_best_time unless @final_results
    @final_results[:trace].each do |trace|
      trace.each_with_index do |task, i|
        if i == trace.size - 1
          output += "#{task}\n"
        else
          output += "#{task} "
        end
      end
    end
    output += "%0.2f" % @final_results[:time]
  end

  class InvalidParam < ArgumentError; end
end