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

def calc_efficiency(challenger_result, model_result)
  raise unless challenger_result.size == model_result.size
  result = 0
  challenger_result.each_index do |i|
    raise unless challenger_result[i][0] == model_result[i][0]
    puts model_result[i][1].to_f / challenger_result[i][1].to_f
    result += model_result[i][1].to_f / challenger_result[i][1].to_f
  end
  
  return result / challenger_result.size 
end





def main()
  model = Proc.new {|x| x} 
  challenger = Proc.new {|x| x - x + x - x + x}
  
  test_set = (1..10000).to_a
  
  
  challenger_result = measure(challenger, test_set)
  model_result = measure(model, test_set)
  puts challenger_result[1]
  puts model_result[1]
  
  #puts calc_efficiency(challenger_result, model_result)
end  
  
main()
