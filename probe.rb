#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'selection'
require_relative 'formula'
require_relative 'mutation'

#50% - 1 mutation
#25% - 2 mutations, and so on
#capped at 8 mutations 
def mutate_n_times(formula)
  count = 10 - Math.log(rand(1..1023), 2).floor
  #count = 1DD
  count.times do
    formula = mutate_Formula(formula)
  end
  return formula
end


def challenge_formula(f)
  Proc.new do |x|
    f.variables = {:x => x}
    f.value
  end
end

Struct.new("Challenger", :formula, :proc, :prev_formula)


model = Proc.new {|x| x ** 2 + 144}
#model = Proc.new {|x| Math.sqrt(x)}
set = (1..10000).to_a

measure(model, set)
model_result = measure(model, set)

base = v :x # y = x
base.variables = {:x => 0}

#Struct::Challenger.new(base, challenge_formula(base))

challengers = []

1000.times do |i|
  challengers << Struct::Challenger.new(base, challenge_formula(base), base)
  
  puts "Round № #{1+i}"
  challengers.each do |chal|
    challengers += 1.times.map {
       mutant = mutate_n_times(chal.formula)
       Struct::Challenger.new(mutant, challenge_formula(mutant), chal.formula)                         }
  end
  
  set = 1000.times.map { rand(1000000) }
  model_result = measure(model, set)
  
  selection = select_challengers(challengers, model_result, set, 25, 25)

  selection.each do |s|
    puts "#{s[0]}  =  #{s[1].formula.string_view}"
  end
  
  challengers = selection.map {|s| s[1]}
end

#puts "Winner: #{selection[0][1].formula.string_view}"










