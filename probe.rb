#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'selection'
require_relative 'formula'
require_relative 'mutation'
require_relative 'species'

=begin #deprecated
def mutate_n_times(formula)
  loop do
    formula = mutate_Formula(formula)
    break if rand < 0.5
  end
  return formula
end
=end


def formula_to_proc(f)
  Proc.new do |x|
    f.variables = {:x => x}
    f.value
  end
end

#Struct.new("Challenger", :formula, :proc, :prev_formula)


model = Proc.new {|x| 8 * x ** 3 - 10 * x ** 2 + 17*x + 4}  #beat in 400 rounds
#model = Proc.new {|x| 10 * x ** 2 + 17*x + 4} #easy for 100 rounds
#model = Proc.new {|x| Math.sqrt(x)} #quite impossible
set = (1..100).to_a

measure(model, set)
model_result = measure(model, set)

#base formula
base = v :x # y = x
base.variables = {:x => 0}

#base species
base = Species.new nil, base

base_result = measure(formula_to_proc(base.code), set)
base_diff = calc_diff(model_result, base_result)
base.efficiency = efficiency(base_diff, base.code.price)

spawners = [base]

puts spawners.inspect

1000000.times do |i|
  
  puts "Round № #{1+i}: "
  puts "Spawners - #{spawners.size}"
  spawners.sort! {|a,b| a.efficiency <=> b.efficiency}
  spawners = spawners.slice(0, 2048)
  spawned  = spawners.map {|s| s.spawn_child}
  
  puts "Best spawner: #{spawners[0].efficiency} (gen. #{spawners[0].generation}) (p. #{spawners[0].code.price})"   
  
  spawned.each do |s|
    #puts s.code.string_view
    s_result = measure(formula_to_proc(s.code), set)
    s_diff = calc_diff(model_result, s_result)
    s.efficiency = efficiency(s_diff, s.code.price)
  end
  spawned.sort! {|a,b| a.efficiency <=> b.efficiency}
  puts "Best spawned: #{spawned[0].efficiency} (gen. #{spawned[0].generation}) (p. #{spawned[0].code.price})"
  
  spawners += spawned

  before = spawners.size 
  
  break if spawners[0].generation < (i - 1000)
end

10.times do |i|
  puts spawners[i].code.string_view
end

=begin


challengers = []
selection = []
same = 0
prev_best = nil

challengers << Struct::Challenger.new(base, challenge_formula(base), base)

100000.times do |i|
  print "Round № #{1+i}: "
  challengers.each do |chal|
    challengers += 1.times.map {
       mutant = mutate_n_times(chal.formula)
       Struct::Challenger.new(mutant, challenge_formula(mutant), chal.formula)                         }
  end
  
  #set = 100.times.map { rand(1000) }
  #model_result = measure(model, set)
  
  selection = select_challengers(challengers, model_result, set, 30, 70)

  if prev_best == selection[0][1]
    same += 1
  else
    same = 0
  end
  prev_best = selection[0][1]
  
  1.times do |i|
    puts "#{selection[i][0]} = #{selection[i][1].formula.price} (#{selection[i][1].object_id}) (#{same})"# {s[2][1].formula.string_view}"
  end    

  break if same >= 500 
  
  challengers = selection.map {|s| s[1]}
end

selection.each do |s|
  puts "#{s[0]}  =  #{s[1].formula.string_view}"
end
#puts "Winner: #{selection[0][1].formula.string_view}"

=end








