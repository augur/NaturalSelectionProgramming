#!/usr/bin/env ruby
# encoding: utf-8



def complex_test(proc, args_array) 
  args_array.map do |args|
    single_run(proc, args)  
  end
end

#Duration of each run must be below 1 second
def single_run(proc, args)
  b = Time.now.nsec
  result = proc.call(args)
  e = Time.now.nsec
  duration = (e > b) ? e - b : 1000000000 - e - b
  return result, duration
end
    
    
