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
  return result, duration
end

def calc_diff(model, challenger)
  diff_sum = 0.0
  challenger[0].each_index do |i|
    diff_sum += (challenger[0][i].to_f - model[0][i].to_f).abs
  end
  return diff_sum / model[0].size, challenger[1].to_f / model[1].to_f
end

def efficiency(diff) 
  return (diff[0] + 1) * (diff[1])

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

