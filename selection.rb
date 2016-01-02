#!/usr/bin/env ruby
# encoding: utf-8


#Duration of each run must be below 1 second
def measure(proc, args_array)
  b = Time.now.nsec
  result = args_array.map do |args|
    proc.call(args)
  end
  e = Time.now.nsec
  duration = (e > b) ? e - b : 1000000000 - e - b
  return result
end

def calc_diff(model, challenger)
  diff_sum = 0.0
  max = nil
  challenger.each_index do |i|
    diff = (challenger[i].to_f - model[i].to_f).abs
    diff_sum += diff
    if max.nil?
      max = diff
    elsif diff > max
      max = diff
    end
  end
  begin
  return max + diff_sum / challenger.size
  rescue
    puts diffs
    puts "error"
    exit
  end
end

def efficiency(diff, price)
  if diff.nan? 
    return Float::INFINITY
  end
  if diff > 0.01
    return 1000000 + diff
  else
    return price
  end
end


def select_challengers(chals, model_result, test_set, quota_best, quota_random)
  results = chals.map do |chal|
    #begin
      [efficiency(calc_diff(model_result, measure(chal.proc, test_set))[0], chal.formula.price), chal]
    #rescue
    #  puts chal.formula.string_view
    #  exit
    #end
  end
  results.sort! {|a,b| a[0] <=> b[0]}
  best = results.slice(0, quota_best)
  random = []
  rest = results.slice(quota_best..-1) || []
  
  #puts "Results: #{results.size}, best:#{best.size}, rest:#{rest.size}"
  
  quota_random.times do 
    break if rest.empty? 
    random << rest.delete_at(rand(rest.size))
  end
  
  return best + random
end
  






if __FILE__ == $0
  model = Proc.new {|x| x ** 2 - 3} 
  challenger1 = Proc.new {|x| x*x + 5}
  challenger2 = Proc.new {|x| 10*x - 100}
  
  test_set = (1..10000).to_a

  #dry run    
  measure(model, test_set)

  model_result = measure(model, test_set)
  ch1_result = measure(challenger1, test_set)
  ch2_result = measure(challenger2, test_set)

  puts "ch1: #{ch1_result[1]}"
  puts "ch2: #{ch2_result[1]}"
  puts "mod: #{model_result[1]}"

  ch1_diff = calc_diff(model_result, ch1_result)
  ch2_diff = calc_diff(model_result, ch2_result)

  puts "ch1_diff: #{ch1_diff[0]}, #{ch1_diff[1]}"
  puts "ch2_diff: #{ch2_diff[0]}, #{ch2_diff[1]}"

  puts efficiency(ch1_diff)
  puts efficiency(ch2_diff)
  
  
  #puts calc_efficiency(challenger_result, model_result)
end

